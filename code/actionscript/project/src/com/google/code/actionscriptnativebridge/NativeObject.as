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
      
      var objectName:String = getQualifiedClassName(this).replace("::", ".");
      var methodName:String = objectName + "#" + name;
      
      __logger.debug("Calling {0}", methodName);
      
      return NativeBridge.instance.callNativeMethod(methodName, rest);
      
   }
    
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeBridge);
    
  }
}