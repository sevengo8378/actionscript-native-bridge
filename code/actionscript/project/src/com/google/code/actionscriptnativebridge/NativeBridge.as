package com.google.code.actionscriptnativebridge
{
  import com.google.code.actionscriptnativebridge.callback.FaultCallback;
  import com.google.code.actionscriptnativebridge.callback.ResultCallback;
  import com.google.code.actionscriptnativebridge.error.SingletonError;
  import com.google.code.actionscriptnativebridge.event.NativeMessageEvent;
  import com.google.code.actionscriptnativebridge.event.NativeRequestEvent;
  import com.google.code.util.LoggingUtil;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.SecurityErrorEvent;
  import flash.utils.Dictionary;
  import flash.utils.Proxy;
  
  import mx.logging.ILogger;
  import mx.logging.Log;
  import mx.utils.ObjectUtil;
  
  [Event(name="activate", type="flash.events.Event")]
  [Event(name="deactivate", type="flash.events.Event")]
  [Event(name="close", type="flash.events.Event")]
  [Event(name="ioError", type="flash.events.IOErrorEvent")]
  [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
  
  public dynamic class NativeBridge 
    extends Proxy 
    implements IEventDispatcher 
  {
    public function NativeBridge()
    {
      if (__INSTANCE != null)
      {
        throw new SingletonError();
      }
      __dispatcher = new EventDispatcher();
      __connection = new NativeConnection();
      
      __connection.addEventListener(Event.ACTIVATE, __forwardEvent);
      __connection.addEventListener(Event.DEACTIVATE, __forwardEvent);
      __connection.addEventListener(Event.CLOSE, __forwardEvent);
      __connection.addEventListener(IOErrorEvent.IO_ERROR, __forwardEvent);
      __connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __forwardEvent);
      
      __connection.addEventListener(NativeMessageEvent.MESSAGE_RECEIVED, __handleMessage);
      
      __connection.open();
    }
    
    public static function get instance():NativeBridge
    {
      return __INSTANCE;
    } 
    
    public function addFunctionHandler(operation:String, handler:Function):void
    {
      addEventListener(
        operation,
        function (e:NativeRequestEvent):void
        {
          try
          {
            e.resultData = handler.apply(null, e.arguments);
          }
          catch (error:Error)
          {
            e.status = 1;
            e.resultData = error;
          }
          e.sendResponse();
        }
      );
    }
    
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
      __dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
      __dispatcher.removeEventListener(type, listener, useCapture);
      
    }
    
    public function dispatchEvent(event:Event):Boolean
    {
      return __dispatcher.dispatchEvent(event);
    }
    
    public function willTrigger(type:String):Boolean
    {
      return __dispatcher.willTrigger(type);
    }
    
    public function hasEventListener(type:String):Boolean
    {
      return __dispatcher.hasEventListener(type);
    }
    
    flash.utils.flash_proxy override function callProperty(name:*, ...rest):*
    {
      __logger.debug("Call to native method started.");
      
      var operation:String = name;
      var arguments:Array = new Array();
      var resultCallback:ResultCallback = null;
      var faultCallback:FaultCallback = null;
      
      if (rest != null)
      {
        for each (var argument:* in rest)
        {
          if (argument is ResultCallback)
          {
            __logger.debug("ResultCallback found.");
            resultCallback = ResultCallback(argument);
          }
          else if(argument is FaultCallback)
          {
            __logger.debug("FaultCallback found.");
            faultCallback = FaultCallback(argument);
          }
          else
          {
            arguments.push(argument);
          }
          
        }

      }
      
      if (Log.isInfo())
      {
        __logger.info(
          "\nNative Operation:\n-----------------\nOperation: {0}, \nParameters: [{1}], \nResult Callback: {2}, \nFault Callback: {3}", 
          operation, 
          arguments, 
          (resultCallback != null), 
          (faultCallback != null)
        );
      }
      
      var requestId:int = __nextRequestId;
      
      var responder:NativeResponder = new NativeResponder(resultCallback, faultCallback);
      __pushResponder(requestId, responder);
      
      var message:Object = new Object();
      message.type = "REQUEST";
      message.requestId = requestId;
      message.operation = operation;
      message.arguments = arguments;
      
      __connection.send(message);
    }
    
    private static const __INSTANCE:NativeBridge = new NativeBridge();
    
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeBridge);
    
    private var __dispatcher:EventDispatcher;
    
    private var __connection:NativeConnection;
    
    private var __responders:Dictionary = new Dictionary();
    
    private var __functionHandlers:Dictionary = new Dictionary();
    
    /**
     * Contador usado para gerar os request IDs sequecialmente.
     */
    private static var __requestCounter:int = 1;
    
    private function __handleMessage(event:NativeMessageEvent):void
    {
      var message:Object = event.message;
      var requestId:int = message.requestId;
      
      if (Log.isInfo())
      {
        __logger.info("New message received: {0}", ObjectUtil.toString(message));
      }
       
      // Verifica se a resposta é relativa à alguma requisição ou se trata de uma notificação.
      switch (message.type)
      {
        // Se for uma resposta...
        case "RESPONSE":
        {
          var responder:NativeResponder = __popResponder(requestId);

          if (responder != null)
          {
            responder.processResponse(message);
          }
          else
          {
            __logger.warn("Unknown request identifier: {0}. It will be ignored", requestId);
          }
        }
        break;
        
        // Se for uma notificação...
        case "REQUEST":
        {
          //dispatchEvent(new NotificationEvent(receivedMessage.notificationId, receivedMessage.data));
          __processRequest(message);
        }
        break;
        
        default:
          __logger.warn("Unknown message type: {0}", message.type); 
        break;
      }
    }
    
    private function __forwardEvent(event:Event):void
    {
      dispatchEvent(event);
    }
    
    /**
     * Armazena um objeto NativeRequest contendo os dados de uma requisição.
     * 
     * @param id Id da requisição.
     * @request Objeto representando a requisição. 
     */
    private function __pushResponder(requestId:int, responder:NativeResponder):void
    {
      __responders[requestId] = responder;
    }
    
    /**
     * Recupera um request ateriormente armazenado.
     * 
     * @param id Id do request a ser recuperado.
     */
    private function __popResponder(requestId:int):NativeResponder
    {
      var responder:NativeResponder = __responders[requestId];
      __responders[requestId] = null;
      delete __responders[requestId];
      
      return responder;
    }
    
    /**
     * Retorna o próximo requestId dispoível.
     */
    private function get __nextRequestId():int
    {
      return __requestCounter++;
    }
    
    private function __processRequest(message:Object):void
    {
      var requestId:int = message.requestId;
      var operation:String = message.operation;
      var arguments:Array = message.arguments;
      
      __logger.debug("Processing request: {0}", requestId);
      __logger.debug("Operation: {0}, Arguments: {1}", operation, arguments);
      
      var event:NativeRequestEvent = new NativeRequestEvent(
        requestId,
        operation,
        arguments,
        function (result:NativeRequestEvent):void
        {
          var responseMessage:Object = new Object();
          responseMessage.type = "RESPONSE";
          responseMessage.requestId = requestId;
          responseMessage.status = result.status;
          responseMessage.data = result.resultData;
      
          __connection.send(responseMessage);
        }
      );
      
      dispatchEvent(event);
    }

  }
}