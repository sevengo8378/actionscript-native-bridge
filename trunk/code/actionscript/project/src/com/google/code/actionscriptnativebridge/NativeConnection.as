package com.google.code.actionscriptnativebridge
{
  
  import com.google.code.actionscriptnativebridge.event.ExecutionErrorEvent;
  import com.google.code.actionscriptnativebridge.event.NativeMessageEvent;
  import com.google.code.actionscriptnativebridge.translator.IMessageTranslator;
  import com.google.code.actionscriptnativebridge.translator.JsonMessageTranslator;
  import com.google.code.util.LoggingUtil;
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.net.Socket;
  import flash.utils.ByteArray;
  
  import mx.logging.ILogger;
  
  [Event(name="close", type="flash.events.Event")]
  [Event(name="ioError", type="flash.events.IOErrorEvent")]
  [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
  [Event(name="messageReceived", type="com.pcmnac.actionscriptnativebridge.event.NativeMessageEvent")]
  
  
  public class NativeConnection extends EventDispatcher
  {
    public function NativeConnection(
      host:String = "127.0.0.1", 
      port:int = 2302, 
      charset:String = "utf-8",
      translator:IMessageTranslator = null)
    {
      if (translator == null)
      {
        __logger.debug("No IMessageTranslator passed. The default one will be used.");
        translator = new JsonMessageTranslator();
      }
      
      __host = host;
      __port = port;
      __charset = charset;
      __translator = translator;
    }
    
    public function open():void
    {
      __socket = new Socket();
      
      __socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __forwardEvent);
      __socket.addEventListener(IOErrorEvent.IO_ERROR, __forwardEvent);
      __socket.addEventListener(Event.CLOSE, __forwardEvent);
      
      __socket.addEventListener(ProgressEvent.SOCKET_DATA, __onSocketData);
     
      __logger.info("Opening socket connection to {0}:{1}.", __host, __port); 
      __socket.connect(__host, __port);
    }
    
    public function send(message:Object):void
    {
      var requestString:String = __translator.stringFromMessage(message); 

      __logger.info("Native request sent:\n{0}", requestString);

      __socket.writeMultiByte(requestString, __charset);
      __socket.writeByte(0);
      __socket.flush();

    }
    
    
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeConnection);
    
    /**
     * Terminador padrão para as mensagens recebidas do módulo background.
     */
    private var __translator:IMessageTranslator;
    
    /**
     * Socket utilizado para a comunicação.
     */
    private var __socket:Socket;
    
    /**
     * Endereço do servidor (socket).
     */
    private var __host:String;
    
    /**
     * Porta do servidor (socket).
     */
    private var __port:int;
    
    /**
     * Charset usado na comunicação.
     */
    private var __charset:String;
    
    /**
     * Buffer para armazenar a resposta recebida. A respota pode chegar em vários pedaços, por
     * isso é necessário um buffer para armazenar esses bytes.
     */
    private var __responseDataBuffer:String = "";
    
    /**
    * Passa o evento para frente.
    */    
    private function __forwardEvent(e:Event):void
    {
      dispatchEvent(e);
    }
    
    /**
     * Trata os dados recebidos da aplicação background.
     * 
     * @param e Evento contendo os bytes recebidos.
     */
    private function __onSocketData(e:ProgressEvent):void
    {
      try
      {
        __logger.debug("{0} bytes received.", __socket.bytesAvailable);
        var messageBlock:ByteArray = new ByteArray();
        
        // Enquanto existirem dados disponíveis...
        while (__socket.bytesAvailable > 0)
        {
          // Lê o byte.
          var b:int = __socket.readByte();
          
          // Se for direfente de 0...
          if (b != 0)
          {
            // Escreve o byte no bloco atual.
            messageBlock.writeByte(b);
          }
          else
          {
            // Se for 0, ou seja, o final de um bloco...
            // processa esse bloco.
            __processMessageBlock(messageBlock, true);
            
            // Reinicia o bloco atual.
            messageBlock = new ByteArray();
          }
        }
        
        // Ao final é necessário processar o bloco, pois pode ser uma mensagem que foi quebrada em várias partes
        // e nesse caso todos os bytes serão lidos porém não será encontrado o 0 (terminador de bloco).
        __processMessageBlock(messageBlock);
      }
      catch(error:Error)
      {
        dispatchEvent(new ExecutionErrorEvent(error));
      }
    }

    /**
     * Processes message blocks received from server.
     * 
     * @param bytes Message block bytes.
     * @param finish Indicates if the end of message was reached.
     */
    private function __processMessageBlock(bytes:ByteArray, finish:Boolean = false):void
    {
      // Rewinds byte array cursor.
      bytes.position = 0;
      
      if (bytes.bytesAvailable > 0)
      {
        var receivedData:String = bytes.readMultiByte(bytes.bytesAvailable, __charset);
        __logger.debug("Data received: {0}", receivedData);

        // Adiciona a mensagem ao buffer.
        __responseDataBuffer += receivedData;
        
        if (finish)
        {
          var messageString:String = __responseDataBuffer;
          __responseDataBuffer = "";
          
          __logger.info("Message received [{0}]: {1}", messageString.length, messageString);
          
          var receivedMessage:Object = __translator.messageFromString(messageString);
          var event:NativeMessageEvent = new NativeMessageEvent(NativeMessageEvent.MESSAGE_RECEIVED, receivedMessage);
          
          dispatchEvent(event);
        }
      }
    }

  }
}