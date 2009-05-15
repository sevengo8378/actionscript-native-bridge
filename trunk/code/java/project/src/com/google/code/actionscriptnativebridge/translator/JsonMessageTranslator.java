package com.google.code.actionscriptnativebridge.translator;

import net.sf.json.JSONObject;

import com.google.code.actionscriptnativebridge.message.Message;
import com.google.code.actionscriptnativebridge.message.RequestMessage;
import com.google.code.actionscriptnativebridge.message.ResponseMessage;

public class JsonMessageTranslator implements IMessageTranslator
{

  public Message messageFromString(String message)
  {

    Message result = null;

    JSONObject object = JSONObject.fromObject(message);

    int requestId = object.getInt("requestId");

    if (object.getString("type").equals(Message.Type.REQUEST.name()))
    {
      String operation = object.getString("operation");
      Object[] arguments = object.getJSONArray("arguments").toArray();
      result = new RequestMessage(requestId, operation, arguments);
    }
    else if (object.getString("type").equals(Message.Type.RESPONSE.name()))
    {
      // TODO
      int status = object.getInt("status");
      Object data = object.get("data");

      result = new ResponseMessage(requestId, status, data);
    }
    else
    {

    }

    return result;
  }

  public String stringFromMessage(Message message)
  {
    return JSONObject.fromObject(message).toString();
  }
}
