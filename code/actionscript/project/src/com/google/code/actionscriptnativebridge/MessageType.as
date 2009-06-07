

package com.google.code.actionscriptnativebridge
{
  /**
   * <p>Message Types sent to and received from native módule.
   * </p>
   *
   * @author <a href="mailto:pcmnac@cesar.org.br">pcmnac++</a>.
   */
  public class MessageType
  {
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