/* ------------------------------------------------------------------------------------------------------
 *
 * File: NativeResponder.as
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
  import com.google.code.actionscriptnativebridge.callback.Callback;
  import com.google.code.actionscriptnativebridge.callback.FaultCallback;
  import com.google.code.actionscriptnativebridge.callback.ResultCallback;
  import com.google.code.util.LoggingUtil;
  
  import mx.logging.ILogger;
  import mx.logging.Log;
  import mx.utils.ObjectUtil;
  
  /**
   * <p>Used to wait for native module responses. For each sent request, is created
   * a responder to wait for the response to this request.
   * </p>
   *
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
   */
  public class NativeResponder
  {
    
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Constructor.
     * 
     * @param resultCallback The result callback reference.
     * @param faultCallback The fault callback reference.
     * @param nativeObject The native object which generated the request.
     */
    public function NativeResponder(
      resultCallback:ResultCallback, 
      faultCallback:FaultCallback,
      nativeObject:NativeObject)
    {
      __resultCallback = resultCallback;
      __faultCallback = faultCallback;
      __nativeObject = nativeObject;
    }
    
    /**
     * Processes the response message. This method is reponsible for calling the
     * callbacks and setting the object IDs.
     * 
     * @param message The response message.
     */
    public function processResponse(message:Object):void
    {
      var requestId:int = message.requestId;
      var data:Object = message.data;
      var status:int = message.statusCode;
      var callback:Callback = (status == ResultStatus.SUCCESS) ? __resultCallback : __faultCallback;

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
        callback.call(data);
      }

    }
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * The Logger for this class.
     */
    private static var __logger:ILogger = LoggingUtil.getClassLogger(NativeResponder);
  
    /**
     * The result callback.
     */
    private var __resultCallback:ResultCallback;
    
    /**
     * The fault callback.
     */
    private var __faultCallback:FaultCallback;
    
    /**
     * The native object which generated the request.
     */
    private var __nativeObject:NativeObject;

  }
}