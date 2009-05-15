package com.google.code.actionscriptnativebridge.message;

public class RequestMessage extends Message
{

  public String getOperation()
  {
    return __operation;
  }

  public void setOperation(String operation)
  {
    this.__operation = operation;
  }

  public Object[] getArguments()
  {
    return __arguments;
  }

  public void setArguments(Object[] arguments)
  {
    __arguments = arguments;
  }

  public RequestMessage(int requestId, String operation, Object[] arguments)
  {
    super(Type.REQUEST, requestId);
    setOperation(operation);
    setArguments(arguments);
  }

  private String __operation;

  private Object[] __arguments;

}
