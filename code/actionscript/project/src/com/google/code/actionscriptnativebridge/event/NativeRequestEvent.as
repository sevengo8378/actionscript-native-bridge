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
  import flash.events.Event;

  /**
   * <p>Representa uma notificação enviada pelo módulo Background.
   * </p>
   *
   * @author <a href="mailto:pcmnac@cesar.org.br">pcmnac</a>.
   */
  public class NativeRequestEvent extends Event
  {

    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Construtor
     * 
     * @param notificationId Identificador da notificação.
     * @param data Dados da notificação.
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
     * Recupera o Id da notificação.
     * 
     * @return O Id da notificação.
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
     * identificador da notificação. Indica o tipo de notificação em questão.
     */
    private var __requestId:int;
    
    /**
     * Dados enviados na notificação. Depende do tipo de notificação.
     */
    private var __operation:String;
    
    private var __arguments:Array;
    
    private var __resultHandler:Function;
    
    private var __status:int = 0;
    
    private var __resultData:Object;
    
  }
}