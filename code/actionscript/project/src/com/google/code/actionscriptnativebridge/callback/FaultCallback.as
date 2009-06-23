package com.google.code.actionscriptnativebridge.callback
{
  public class FaultCallback extends Callback
  {
    public function FaultCallback(callback:Function)
    {
      super(callback);
    }
    
    public override function handleResponse(requestId:int, status:int, data:Object):void
    {
      callback.call(null, data);
    }
    
  }
}