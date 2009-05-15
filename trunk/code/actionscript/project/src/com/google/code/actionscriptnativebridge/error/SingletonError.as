package com.google.code.actionscriptnativebridge.error
{
  public class SingletonError extends Error
  {
    public function SingletonError(message:String = "Duplicated singleton instance attempt.", id:int=0)
    {
      super(message, id);
    }
    
  }
}