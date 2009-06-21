package com.google.code.actionscriptnativebridge
{
  import com.google.code.util.LoggingUtil;
  
  import flash.utils.Proxy;
  import flash.utils.getQualifiedClassName;
  
  import mx.logging.ILogger;

  public dynamic class NativeObject extends Proxy
  {
    public function NativeObject()
    {
      super();
    }
    
    flash.utils.flash_proxy override function callProperty(name:*, ...rest):*
    {
      __logger.debug("Call to native method started.");
      
      var objectId:String = __nativeId != null ? 
        __nativeId : 
        getQualifiedClassName(this).replace("::", ".");
      var methodName:String = objectId + "#" + name;
      
      __logger.debug("Calling {0}", methodName);
      
      if (__nativeId == null)
      {
        rest.push(this);
      }
      
      return NativeBridge.instance.callNativeMethod(methodName, rest);
      
    }
    
    public function set nativeId(value:String):void
    {
      __nativeId = value;
    }
    
    private var __nativeId:String;
    
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeObject);
    
  }
}