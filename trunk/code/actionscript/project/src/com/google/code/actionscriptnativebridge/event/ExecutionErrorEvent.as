
package com.google.code.actionscriptnativebridge.event
{
  import flash.events.Event;

  /**
   * <p>Representa um erro de execução.
   * </p>
   *
   * @author <a href="mailto:pcmnac@cesar.org.br">pcmnac</a>.
   */
  public class ExecutionErrorEvent extends Event
  {

    // --------------------------------------------------------------------------------
    // API pública
    // --------------------------------------------------------------------------------
    
    /**
     * Id do evento usado para se registrar.
     */ 
    public static const EXECUTION_ERROR:String = "executionError";

    /**
     * Construtor.
     * 
     * @param error ID do request que deu origem ao erro.
     */
    public function ExecutionErrorEvent(error:Error)
    {
      super(EXECUTION_ERROR);
      __error = error;
    }
    
    /**
     * Recupera o erro ocorrido.
     * 
     * @return O erro ocorrido.
     */
    public function get error():Error
    {
      return __error;
    }
    
 
    // --------------------------------------------------------------------------------
    // Membros protegidos.
    // --------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------
    // Membros privados.
    // --------------------------------------------------------------------------------
    
    /**
     * Erro ocorrido.
     */
    private var __error:Error;
 
  }
}