package com.google.code.actionscriptnativebridge.translator
{
  public interface IMessageTranslator
  {
    function messageFromString(message:String):Object;

    function stringFromMessage(message:Object):String;

  }
}