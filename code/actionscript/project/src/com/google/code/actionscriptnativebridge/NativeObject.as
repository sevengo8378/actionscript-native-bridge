/* ------------------------------------------------------------------------------------------------------
 *
 * File: NativeObject.as
 *
 *                                             Revision History
 * ------------------------------------------------------------------------------------------------------
 * Author (username)                    Date      CR Number   Comments
 * --------------------------------  ----------  -----------  -------------------------------------------
 * Paulo Coutinho (pcmnac)           2009.04.10               Initial creation.
 * ------------------------------------------------------------------------------------------------------
 */
 
package com.google.code.actionscriptnativebridge
{
  import com.google.code.util.LoggingUtil;
  
  import flash.utils.Proxy;
  import flash.utils.getQualifiedClassName;
  
  import mx.logging.ILogger;

  /**
   * The native object base class. Extend this class to make a mirror to a native class
   * with the same name and package. The dynamic methods called from this class are
   * reflected automatically in the correspondent native class. If the native object is
   * stateful, the object reference will be kept. 
   * 
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
   */
  public dynamic class NativeObject extends Proxy
  {
    
    // --------------------------------------------------------------------------------------------------
    // Proxy Visibilty Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * @see Proxy::callProperty.
     */
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
    
    /**
     * Sets the object IDs.
     * 
     * @param value The new value to object ID.
     */
    public function set objectId(value:String):void
    {
      if (value == "")
      {
        value = null;
      }
      
      __objectId = value;
    }
    
    /**
     * The object ID. If the native object has a valid object ID. It will be used to
     * make object specific calls. Otherwise, the qualified class name will be used.
     */
    private var __objectId:String;
    
    /**
     * Logger for this class.
     */
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeObject);
    
  }
}