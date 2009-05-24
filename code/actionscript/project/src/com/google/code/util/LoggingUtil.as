package com.google.code.util
{
  import flash.utils.getQualifiedClassName;
  
  import mx.logging.ILogger;
  import mx.logging.Log;
  
  public class LoggingUtil
  {
    
    public static function getClassLogger(object:Object):ILogger
    {
      return Log.getLogger(getQualifiedClassName(object).replace("::", "."));
    }
    
  }
}