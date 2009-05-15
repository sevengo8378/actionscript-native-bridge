package com.google.code.actionscriptnativebridge.callback
{
  import com.google.code.actionscriptnativebridge.event.FaultEvent;
  
  public class FaultCallback extends Callback
  {
    public function FaultCallback(callback:Function)
    {
      super(callback);
    }
    
    public override function handleResponse(requestId:int, status:int, data:Object):void
    {
      var event:FaultEvent = new FaultEvent(requestId, status, data);
      
      callback.call(null, event);
    }
    
  }
}