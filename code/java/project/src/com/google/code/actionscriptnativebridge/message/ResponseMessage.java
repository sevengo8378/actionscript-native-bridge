package com.google.code.actionscriptnativebridge.message;

public class ResponseMessage extends Message
{

  public ResponseMessage(int requestId, String objectId, int statusCode,
      Object data)
  {
    super(Type.RESPONSE, requestId);
    setObjectId(objectId);
    setStatusCode(statusCode);
    setData(data);
  }

  public int getStatusCode()
  {
    return __statusCode;
  }

  public void setStatusCode(int statusCode)
  {
    this.__statusCode = statusCode;
  }

  public Object getData()
  {
    return __data;
  }

  public void setData(Object data)
  {
    this.__data = data;
  }

  private int __statusCode;

  private Object __data;

}
