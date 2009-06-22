package com.google.code.actionscriptnativebridge
{
  import com.google.code.actionscriptnativebridge.callback.Callback;
  import com.google.code.actionscriptnativebridge.callback.FaultCallback;
  import com.google.code.actionscriptnativebridge.callback.ResultCallback;
  import com.google.code.util.LoggingUtil;
  
  import mx.logging.ILogger;
  import mx.logging.Log;
  import mx.utils.ObjectUtil;
  
  public class NativeResponder
  {
    public function NativeResponder(
      resultCallback:ResultCallback, 
      faultCallback:FaultCallback,
      nativeObject:NativeObject)
    {
      __resultCallback = resultCallback;
      __faultCallback = faultCallback;
      __nativeObject = nativeObject;
    }
    
    public function processResponse(message:Object):void
    {
      var requestId:int = message.requestId;
      var data:Object = message.data;
      var status:int = message.statusCode;
      var callback:Callback = (status == 0) ? __resultCallback : __faultCallback;

      if (Log.isDebug())
      {
        __logger.debug(
          "Response received to requestId {0}:\nStatus: {1}\nData: {2} ",
          requestId,
          status,
          ObjectUtil.toString(data)
        );
      }
      
      if (__nativeObject != null)
      {
        __nativeObject.objectId = message.objectId;
      }

      if (callback != null)
      {
        __logger.debug("Calling {0} callback", ((status == 0) ? "result" : "fault"));
        callback.handleResponse(requestId, status, data);
      }

    }
    
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeResponder);
  
    private var __resultCallback:ResultCallback;
    
    private var __faultCallback:FaultCallback;
    
    private var __nativeObject:NativeObject;

  }
}