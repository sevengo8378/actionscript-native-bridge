/* ------------------------------------------------------------------------------------------------------
 *
 * File: NativeRequestEvent.as
 *
 *                                             Revision History
 * ------------------------------------------------------------------------------------------------------
 * Author (username)                    Date      CR Number   Comments
 * --------------------------------  ----------  -----------  -------------------------------------------
 * Paulo Coutinho (pcmnac)           2009.05.03               Initial creation.
 * ------------------------------------------------------------------------------------------------------
 */
 
package com.google.code.actionscriptnativebridge.event
{
  import com.google.code.actionscriptnativebridge.ResultStatus;
  
  import flash.events.Event;

  /**
   * <p>A native request received from the native module.
   * </p>
   *
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac</a>.
   */
  public class NativeRequestEvent extends Event
  {

    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Construtor
     * 
     * @param requestId The request identifier.
     * @param operation The requested operation.
     * @param arguments The request arguments.
     * @param resultHandler The result handler.
     */
    public function NativeRequestEvent(
      requestId:int, 
      operation:String, 
      arguments:Array,
      resultHandler:Function)
    {
      super(operation);
      __requestId = requestId;
      __operation = operation;
      __arguments = arguments;
      __resultHandler = resultHandler;
    }
    
    /**
     * Retrieved the request ID.
     * 
     * @return The native request ID.
     */
    public function get requestId():int
    {
      return __requestId;
    }
    
    public function get operation():String
    {
      return __operation;
    }
    
    /**
     * Recupera os dados da notificação.
     * 
     * @return Os dados da notificação.
     */
    public function get arguments():Array
    {
      return __arguments;
    }
    
    public function get status():int
    {
      return __status;
    }
    
    public function set status(value:int):void
    {
      __status = status;
    }
    
    public function get resultData():Object
    {
      return __resultData;
    }
    
    public function set resultData(value:Object):void
    {
      __resultData = value;
    }
    
    public function sendResponse():void
    {
      __resultHandler(this);;
    }
    
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * The request identifier.
     */
    private var __requestId:int;
    
    /**
     * The requested operation name.
     */
    private var __operation:String;
    
    /**
     * The request arguments.
     */
    private var __arguments:Array;
    
    /**
     * The result handler for this request.
     */
    private var __resultHandler:Function;
    
    private var __status:int = ResultStatus.SUCCESS;
    
    private var __resultData:Object;
    
  }
}