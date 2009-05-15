package com.google.code.actionscriptnativebridge.translator
{
  import com.adobe.serialization.json.JSON;
  
  public class JsonMessageTranslator implements IMessageTranslator
  {
    public function JsonMessageTranslator()
    {
    }
    
    public function messageFromString(message:String):Object
    {
      return JSON.decode(message);
    }

    public function stringFromMessage(message:Object):String
    {
      return JSON.encode(message);
    }


  }
}