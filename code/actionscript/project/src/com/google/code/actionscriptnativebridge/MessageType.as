

package com.google.code.actionscriptnativebridge
{
  /**
   * <p>Tipos de mensagens que podem ser recebidas da aplicação de background.
   * </p>
   *
   * @author <a href="mailto:pcmnac@cesar.org.br">pcmnac</a>.
   */
  public class MessageType
  {
    /**
     * Representa uma resposta a uma requisição iniciada.
     */
    public static const RESPONSE:int = 0;
    
    /**
     * Representa uma notificação iniciada pelo módulo background. 
     */
    public static const REQUEST:int = 1;
  }
}