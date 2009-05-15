package com.google.code.actionscriptnativebridge.callback
{
  import com.google.code.actionscriptnativebridge.event.ResultEvent;
  

  public class ResultCallback extends Callback
  {
    public function ResultCallback(callback:Function)
    {
      super(callback);
    }
    
    public override function handleResponse(requestId:int, status:int, data:Object):void
    {
      var event:ResultEvent = new ResultEvent(requestId, data);
      
      callback.call(null, event);
    }
    
  }
}