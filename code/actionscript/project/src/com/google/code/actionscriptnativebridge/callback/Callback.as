package com.google.code.actionscriptnativebridge.callback
{
  import com.google.code.actionscriptnativebridge.error.AbstractMethodCallError;
  
  public class Callback
  {
    public function Callback(callback:Function)
    {
      __callback = callback;
    }
    
    public function get callback():Function
    {
      return __callback;
    }
    
    public function handleResponse(requestId:int, status:int, data:Object):void
    {
      throw new AbstractMethodCallError();
    }
    
    private var __callback:Function;

  }
}