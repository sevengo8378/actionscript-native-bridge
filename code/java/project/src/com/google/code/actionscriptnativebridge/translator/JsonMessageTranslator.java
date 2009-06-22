package com.google.code.actionscriptnativebridge.translator;

import net.sf.json.JSONObject;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.code.actionscriptnativebridge.message.Message;
import com.google.code.actionscriptnativebridge.message.RequestMessage;
import com.google.code.actionscriptnativebridge.message.ResponseMessage;

public class JsonMessageTranslator implements IMessageTranslator
{

  public Message messageFromString(String message)
  {

    Message result = null;

    try
    {

      JSONObject object = JSONObject.fromObject(message);

      int requestId = object.getInt("requestId");
      String objectId = object.optString("objectId");

      if (object.getString("type").equals(Message.Type.REQUEST.name()))
      {
        String operation = object.getString("operation");
        Object[] arguments = object.getJSONArray("arguments").toArray();

        result = new RequestMessage(requestId, objectId, operation, arguments);
      }
      else if (object.getString("type").equals(Message.Type.RESPONSE.name()))
      {
        int status = object.getInt("status");
        Object data = object.get("data");

        result = new ResponseMessage(requestId, objectId, status, data);
      }
      else
      {
        __logger.warn("Unknown message type: " + object.getString("type"));
      }
    }
    catch (Exception e)
    {
      __logger.error("error parsing the message.", e);
    }

    return result;
  }

  public String stringFromMessage(Message message)
  {
    return JSONObject.fromObject(message).toString();
  }

  private Log __logger = LogFactory.getLog(JsonMessageTranslator.class);
}
