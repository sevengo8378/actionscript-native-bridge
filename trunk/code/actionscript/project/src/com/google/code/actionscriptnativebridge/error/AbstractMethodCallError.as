package com.google.code.actionscriptnativebridge.error
{
  public class AbstractMethodCallError extends Error
  {
    public function AbstractMethodCallError(message:String = "Abstract method called.", id:int=0)
    {
      super(message, id);
    }
    
  }
}