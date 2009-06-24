/* ------------------------------------------------------------------------------------------------------
 *
 * File: FaultCallback.as
 *
 *                                             Revision History
 * ------------------------------------------------------------------------------------------------------
 * Author (username)                    Date      CR Number   Comments
 * --------------------------------  ----------  -----------  -------------------------------------------
 * Paulo Coutinho (pcmnac)           2009.04.10               Initial creation.
 * ------------------------------------------------------------------------------------------------------
 */

package com.google.code.actionscriptnativebridge.callback
{
  
  /**
   * Holds a callback function to be invoked in case of error.
   * 
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
   */
  public class FaultCallback extends Callback
  {
    
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Constructor.
     * 
     * @param callback The callback function.
     */
    public function FaultCallback(callback:Function)
    {
      super(callback);
    }
    
  }
}