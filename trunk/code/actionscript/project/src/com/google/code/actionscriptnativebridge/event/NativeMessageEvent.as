package com.google.code.actionscriptnativebridge.event
{
  import flash.events.Event;

  public class NativeMessageEvent extends Event
  {
    
    public static const MESSAGE_RECEIVED:String = "messageReceived";
    
    public function NativeMessageEvent(
      type:String, 
      message:Object, 
      bubbles:Boolean = false, 
      cancelable:Boolean = false)
    {
      super(type, bubbles, cancelable);
      __message = message;
    }
    
    public function get message():Object
    {
      return __message;
    }
    
    private var __message:Object;
    
  }
}