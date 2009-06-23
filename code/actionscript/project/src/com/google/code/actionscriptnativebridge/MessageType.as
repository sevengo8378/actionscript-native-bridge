/* ------------------------------------------------------------------------------------------------------
 *
 * File: MessageType.as
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
  /**
   * <p>Message Types sent to and received from native module.
   * </p>
   *
   * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
   */
  public class MessageType
  {
    
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * A request message. 
     */
    public static const REQUEST:String = "REQUEST";
    
    /**
     * A response message to a previously received request.
     */
    public static const RESPONSE:String = "RESPONSE";
    
  }
}