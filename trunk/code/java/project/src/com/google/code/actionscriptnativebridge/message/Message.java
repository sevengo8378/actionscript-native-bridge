package com.google.code.actionscriptnativebridge.message;

public abstract class Message
{

  public enum Type
  {
    REQUEST, RESPONSE
  }

  public Message(Type type, int requestId)
  {
    setType(type);
    setRequestId(requestId);
  }

  public Type getType()
  {
    return __type;
  }

  public void setType(Type type)
  {
    __type = type;
  }

  public int getRequestId()
  {
    return __requestId;
  }

  public void setRequestId(int requestId)
  {
    __requestId = requestId;
  }

  public String getObjectId()
  {
    return __objectId;
  }

  public void setObjectId(String objectId)
  {
    if ((objectId != null) && (objectId.trim().length() == 0))
    {
      objectId = null;
    }
    
    __objectId = objectId;
  }

  private Type __type;

  private int __requestId;

  private String __objectId;

}
