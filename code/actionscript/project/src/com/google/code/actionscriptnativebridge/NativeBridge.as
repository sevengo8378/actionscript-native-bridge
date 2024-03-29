/* ------------------------------------------------------------------------------------------------------
 *
 * File: NativeBridge.as
 *
 *                                             Revision History
 * ------------------------------------------------------------------------------------------------------
 * Author (username)                    Date      CR Number   Comments
 * --------------------------------  ----------  -----------  -------------------------------------------
 * Paulo Coutinho (pcmnac)           2009.04.10               Initial creation.
 * ------------------------------------------------------------------------------------------------------
 */
 
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
  
  // --------------------------------------------------------------------------------------------------
  // Events
  // --------------------------------------------------------------------------------------------------
    
  [Event(name="close", type="flash.events.Event")]
  [Event(name="ioError", type="flash.events.IOErrorEvent")]
  [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
  
  /**
   * Native Bridge interface. Use this class to make calls to native methods and listen for native
   * calls.
   * 
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
   */
  public dynamic class NativeBridge 
    extends Proxy 
    implements IEventDispatcher 
  {
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Constructor. Do NOT try to create object of this type. 
     * Instead, use the instance() method to get the unique class instance.
     */
    public function NativeBridge()
    {
      if (__INSTANCE != null)
      {
        throw new SingletonError();
      }
      __dispatcher = new EventDispatcher();
      __nativeRequestDispatcher = new EventDispatcher();
      __connection = new NativeConnection();

      // Sets up the listener for native connection.
      __connection.addEventListener(Event.CLOSE, __forwardEvent);
      __connection.addEventListener(IOErrorEvent.IO_ERROR, __forwardEvent);
      __connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __forwardEvent);
      
      __connection.addEventListener(NativeMessageEvent.MESSAGE_RECEIVED, __handleMessage);
      
      // Opens the native connection.
      __connection.open();
    }
    
    /**
     * Retrieves the bridge singleton instance.
     * 
     * @return The unique bridge instance.
     */
    public static function get instance():NativeBridge
    {
      return __INSTANCE;
    } 
    
    /**
     * Adds a synchronous function handler to a specific native call. 
     * The return of the function will be sent to native module automatically.
     * 
     * @param operation The external operation identifier.
     * @param handler The function which will handle the native call.
     */
    public function addHandler(operation:String, handler:Function):void
    {
      __nativeRequestDispatcher.addEventListener(
        operation,
        function (e:NativeRequestEvent):void
        {
          try
          {
            e.resultData = handler.apply(null, e.arguments);
          }
          catch (error:Error)
          {
            e.status = ResultStatus.FAILURE;
            e.resultData = error;
          }
          e.sendResponse();
        }
      );
    }
    
    /**
     * Adds a asynchronous function handler to a specific native call. 
     * The return of the function will NOT be sent to native module automatically.
     * In this case the function MUST receive, as the last parameter, a 
     * NativeRequestEvent object and it MUST call the sendResponse() method of
     * the received event to sent the result to the native module.
     * 
     * @param operation The external operation identifier.
     * @param handler The function which will handle the native call.
     */
    public function addAsynchronousHandler(operation:String, handler:Function):void
    {
      __nativeRequestDispatcher.addEventListener(
        operation,
        function (e:NativeRequestEvent):void
        {
          try
          {
            e.arguments.push(e);
            handler.apply(null, e.arguments);
          }
          catch (error:Error)
          {
            e.status = ResultStatus.FAILURE;
            e.resultData = error;
            e.sendResponse();
          }
        }
      );
    }
    
    /**
     * @see IEventDispatcher::addEventListener. 
     */
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, 
      priority:int = 0, useWeakReference:Boolean = false):void
    {
      __dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    /**
     * @see IEventDispatcher::removeEventListener. 
     */
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
      __dispatcher.removeEventListener(type, listener, useCapture);
      
    }
    
    /**
     * @see IEventDispatcher::dispatchEvent. 
     */
    public function dispatchEvent(event:Event):Boolean
    {
      return __dispatcher.dispatchEvent(event);
    }
    
    /**
     * @see IEventDispatcher::willTrigger. 
     */
    public function willTrigger(type:String):Boolean
    {
      return __dispatcher.willTrigger(type);
    }
    
    /**
     * @see IEventDispatcher::hasEventListener. 
     */
    public function hasEventListener(type:String):Boolean
    {
      return __dispatcher.hasEventListener(type);
    }
    
    /**
     * Makes a call to a native method.
     * 
     * @param objectId The ID of the object where the operation will be invoked.
     * @param name The method name.
     * @param args The arguments to method.
     */
    public function callNativeMethod(objectId:String, name:String, args:Array):void
    {
      __logger.debug("Call to native method started.");
      
      var operation:String = name;
      var arguments:Array = new Array();
      var resultCallback:ResultCallback = null;
      var faultCallback:FaultCallback = null;
      var nativeObject:NativeObject = null;
      
      if (args != null)
      {
        for each (var argument:* in args)
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
          else if(argument is NativeObject)
          {
            __logger.debug("Native Object found.");
            nativeObject = NativeObject(argument);
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
          "\nNative Operation:\n-----------------\nOperation: {0},\nParameters: [{1}],\nResult Callback: {2},\nFault Callback: {3},\nNative Object: {4}", 
          operation, 
          arguments, 
          (resultCallback != null), 
          (faultCallback != null),
          (nativeObject != null)
        );
      }
      
      var requestId:int = __nextRequestId;
      
      var responder:NativeResponder = 
        new NativeResponder(resultCallback, faultCallback, nativeObject);
      __pushResponder(requestId, responder);
      
      // Creates a message.
      var message:Object = new Object();
      message.type = MessageType.REQUEST;
      message.requestId = requestId;
      if (objectId != null)
      {
        message.objectId = objectId ;
      }
      message.operation = operation;
      message.arguments = arguments;
      
      // Sends the message to native module.
      __connection.send(message);
    }
    
    // --------------------------------------------------------------------------------------------------
    // Proxy Visibilty Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * @see Proxy::callProperty.
     */
    flash.utils.flash_proxy override function callProperty(name:*, ...rest):*
    {
      callNativeMethod(null, name, rest);
    }
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * The bridge instance.
     */
    private static const __INSTANCE:NativeBridge = new NativeBridge();
    
    /**
     * The logger for this class.
     */
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeBridge);
    
    /**
     * The event dispatcher for this class.
     */
    private var __dispatcher:EventDispatcher;
    
    /**
     * The event dispatcher for this class.
     */
    private var __nativeRequestDispatcher:EventDispatcher;
    
    /**
     * The connection to native module.
     */
    private var __connection:NativeConnection;
    
    /**
     * The responders for sent requests.
     */
    private var __responders:Dictionary = new Dictionary();
    
    /**
     * The function handlers to respond to native requests.
     */
    private var __functionHandlers:Dictionary = new Dictionary();
    
    /**
     * Request ID counter. Used to generate sequential IDs.
     */
    private static var __requestCounter:int = 1;
    
    /**
     * Handles a received native message.
     * 
     * @param event The native message event.
     */
    private function __handleMessage(event:NativeMessageEvent):void
    {
      var message:Object = event.message;
      var requestId:int = message.requestId;
      
      if (Log.isInfo())
      {
        __logger.info("New message received: {0}", ObjectUtil.toString(message));
      }
       
      // Checks the message type.
      switch (message.type)
      {
        // If it was a response...
        case MessageType.RESPONSE:
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
        
        // If it was a request message...
        case MessageType.REQUEST:
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
    
    /**
     * Forwards an event.
     * 
     * @param event The event to be forwarded.
     */
    private function __forwardEvent(event:Event):void
    {
      dispatchEvent(event);
    }
    
    /**
     * Stores a Responder object which will be used to handle the response to the given request ID.
     * 
     * @param requestId The request ID.
     * @param responder The responder. 
     */
    private function __pushResponder(requestId:int, responder:NativeResponder):void
    {
      __responders[requestId] = responder;
    }
    
    /**
     * Retrieves the stored Responder object to the given request ID.
     * 
     * @param requestId The request ID.
     * 
     * @return The Responder.
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
    
    /**
     * Processes a request received from the native module.
     * 
     * @param message The request message.
     */
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
          responseMessage.type = MessageType.RESPONSE;
          responseMessage.requestId = requestId;
          responseMessage.status = result.status;
          responseMessage.data = result.resultData;
      
          __connection.send(responseMessage);
        }
      );
      
      __nativeRequestDispatcher.dispatchEvent(event);
    }

  }
}