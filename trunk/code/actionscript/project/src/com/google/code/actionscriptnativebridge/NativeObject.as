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
      
      var objectId:String = __objectId != null ? 
        __objectId : 
        getQualifiedClassName(this).replace("::", ".");
      
      __logger.debug("Calling {0}", objectId + "::" + name);
      
      if (__objectId == null)
      {
        rest.push(this);
      }
      
      return NativeBridge.instance.callNativeMethod(objectId, name, rest);
      
    }
    
    public function set objectId(value:String):void
    {
      if (value == "")
      {
        value = null;
      }
      
      __objectId = value;
    }
    
    private var __objectId:String;
    
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeObject);
    
  }
}