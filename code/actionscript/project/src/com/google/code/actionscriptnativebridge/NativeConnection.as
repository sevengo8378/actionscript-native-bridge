/* ------------------------------------------------------------------------------------------------------
 *
 * File: NativeConnection.as
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
  
  // --------------------------------------------------------------------------------------------------
  // Events
  // --------------------------------------------------------------------------------------------------
  
  [Event(name="close", type="flash.events.Event")]
  [Event(name="ioError", type="flash.events.IOErrorEvent")]
  [Event(name="securityError", type="flash.events.SecurityErrorEvent")]
  [Event(name="messageReceived", type="com.google.code.actionscriptnativebridge.event.NativeMessageEvent")]
  
  /**
   * 
   */
  public class NativeConnection extends EventDispatcher
  {
    
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Contructor.
     * 
     * @param host The native module host.
     * @param port The native module port.
     * @param charset The charset used in the message exchanging.
     * @param translator The IMessageTranslator responsible for serialize and unserialize the messages.
     */
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
    
    /**
     * Opens the connection with the native module.
     */
    public function open():void
    {
      __socket = new Socket();
      
      __socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __forwardEvent);
      __socket.addEventListener(IOErrorEvent.IO_ERROR, __forwardEvent);
      __socket.addEventListener(Event.CLOSE, __forwardEvent);
      
      __socket.addEventListener(Event.CONNECT, __onSocketConnect);
      __socket.addEventListener(ProgressEvent.SOCKET_DATA, __onSocketData);
     
      __logger.info("Opening socket connection to {0}:{1}.", __host, __port); 
      __socket.connect(__host, __port);
    }
    
    /**
     * Sends a message to the native module.
     * 
     * @param message The message to be sent.
     */
    public function send(message:Object):void
    {
      if (__connected)
      {
        var requestString:String = __translator.stringFromMessage(message); 
  
        __logger.info("Native request sent:\n{0}", requestString);
  
        __socket.writeMultiByte(requestString, __charset);
        __socket.writeByte(0);
        __socket.flush();
      }
      else
      {
        __pendingRequests.push(message);
      }
    }
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Logger for this class.
     */
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeConnection);
    
    /**
     * The IMessageTranslator responsible for serialize and unserialize the messages.
     */
    private var __translator:IMessageTranslator;
    
    /**
     * Socket object to manage the communication with the native module.
     */
    private var __socket:Socket;
    
    /**
     * The native module host.
     */
    private var __host:String;
    
    /**
     * The native module port.
     */
    private var __port:int;
    
    /**
     * The charset used in the message exchanging.
     */
    private var __charset:String;
    
    /**
     * Buffer to store the received data until a complete message be received.
     */
    private var __responseDataBuffer:String = "";
    
    private var __pendingRequests:Array = new Array();
    
    private var __connected:Boolean;
    
    /**
     * Forwards the event.
     * 
     * @param e The event to be forwarded.
     */    
    private function __forwardEvent(e:Event):void
    {
      dispatchEvent(e);
    }
    
    private function __onSocketConnect(e:Event):void
    {
      __connected = true;
      
      for each (var message:Object in __pendingRequests)
      {
        send(message);
      }
      
      __pendingRequests = new Array();
    }
    
    /**
     * Handles the data received from the socket connection.
     * 
     * @param e The progress event.
     */
    private function __onSocketData(e:ProgressEvent):void
    {
      try
      {
        __logger.debug("{0} bytes received.", __socket.bytesAvailable);
        var messageBlock:ByteArray = new ByteArray();
        
        // While there are bytes available ...
        while (__socket.bytesAvailable > 0)
        {
          // Reads the next byte.
          var b:int = __socket.readByte();
          
          // If it is not equals to 0 (Zero)...
          if (b != 0)
          {
            // Writes the byte to the block.
            messageBlock.writeByte(b);
          }
          else
          {
            // If the 0 (Zero) byte was found...
            // Process the block.
            __processMessageBlock(messageBlock, true);
            
            // Resets the block to receive the pending bytes.
            messageBlock = new ByteArray();
          }
        }
        
        // Processes the block.
        __processMessageBlock(messageBlock);
      }
      catch(error:Error)
      {
        __logger.error("Execution error {0}: {1}", error.errorID, error.message);
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

        // Adds the received data to the buffer.
        __responseDataBuffer += receivedData;
        
        if (finish)
        {
          var messageString:String = __responseDataBuffer;
          __responseDataBuffer = "";
          
          __logger.info("Message received [{0}]: {1}", messageString.length, messageString);
          
          var receivedMessage:Object = __translator.messageFromString(messageString);
          var event:NativeMessageEvent = new NativeMessageEvent(
            NativeMessageEvent.MESSAGE_RECEIVED, 
            receivedMessage);
          
          dispatchEvent(event);
        }
      }
    }

  }
}