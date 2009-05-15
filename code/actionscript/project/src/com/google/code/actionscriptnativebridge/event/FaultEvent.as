/* ------------------------------------------------------------------------------------------------------
 *
 * File: FaultEvent.as
 *
 *                                             Revision History
 * ------------------------------------------------------------------------------------------------------
 * Author (username)                    Date      CR Number   Comments
 * --------------------------------  ----------  -----------  -------------------------------------------
 * Paulo Coutinho (pcmnac)           2009.04.10               Initial creation.
 * ------------------------------------------------------------------------------------------------------
 */
package com.google.code.actionscriptnativebridge.event
{
  import flash.events.Event;

  /**
   * <p></p>
   *
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac</a>.
   */
  public class FaultEvent extends NativeEvent
  {

    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Id do evento usado para se registrar.
     */
    public static const NATIVE_FAULT:String = "nativeFault";

    /**
     * Construtor.
     * 
     * @param requestId ID do request que deu origem ao erro.
     * @param statusCode Código do erro.
     */
    public function FaultEvent(
      requestId:int, 
      status:int,
      data:Object = null,
      bubbles:Boolean = false, 
      cancelable:Boolean = false)
    {
      super(NATIVE_FAULT, requestId, data, bubbles, cancelable);
      __status = status;       
    }

    /**
     * Retrieves the status code.
     * 
     * @return The status code. 
     */
    public function get status():int
    {
      return __status;
    }
    
 
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * The error status code.
     */
    private var __status:int;
 
  }
}