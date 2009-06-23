package com.google.code.actionscriptnativebridge.callback
{

  public class ResultCallback extends Callback
  {
    public function ResultCallback(callback:Function)
    {
      super(callback);
    }
    
    public override function handleResponse(requestId:int, status:int, data:Object):void
    {
      callback.call(null, data);
    }
    
  }
}