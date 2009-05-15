/* ------------------------------------------------------------------------------------------------------
 *
 * File: ResultEvent.as
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
   * <p>Base class for Native Events.</p>
   *
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac</a>.
   */
  public class ResultEvent extends NativeEvent
  {

    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Id do evento usado para se registrar. 
     */
    public static const NATIVE_RESULT:String = "nativeResult";

    /**
     * Construtor
     * 
     * @param requestId Identificador da requisição que gerou o resultado.
     * @param data Dados do resultado.
     */
    public function ResultEvent(
      requestId:int, 
      data:Object = null,
      bubbles:Boolean = false, 
      cancelable:Boolean = false)
    {
      super(NATIVE_RESULT, requestId, data, bubbles, cancelable);
    }
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
   
  }
}