/* ------------------------------------------------------------------------------------------------------
 *
 * File: Callback.as
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
  import com.google.code.actionscriptnativebridge.error.AbstractMethodCallError;
  
  /**
   * Base class for ResultCallback and FaultCallback.
   * 
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
   */
  public class Callback
  {
    
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Constructor.
     * 
     * @param callback The callback function.
     */
    public function Callback(callback:Function)
    {
      __callback = callback;
    }
    
    /**
     * Retrieves the underlying callback function.
     * 
     * @return The underlying callback function.
     */
    public function get callback():Function
    {
      return __callback;
    }
    
    /**
     * Calls the underlying function.
     * 
     * @param data The data to be passed to the callback function.
     */
    public function call(data:Object):void
    {
      callback.call(null, data);
    }
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * The underlying callback function.
     */
    private var __callback:Function;

  }
}