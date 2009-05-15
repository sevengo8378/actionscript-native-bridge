package com.google.code.actionscriptnativebridge.translator;

import com.google.code.actionscriptnativebridge.message.Message;

public interface IMessageTranslator
{

  Message messageFromString(String message);

  String stringFromMessage(Message message);

}
