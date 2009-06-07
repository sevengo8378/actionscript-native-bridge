package com.google.code.actionscriptnativebridge;

import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.code.actionscriptnativebridge.ActionScriptConnection.MessageListener;
import com.google.code.actionscriptnativebridge.exception.ExecutionException;
import com.google.code.actionscriptnativebridge.exception.MethodNotFoundException;
import com.google.code.actionscriptnativebridge.message.Message;
import com.google.code.actionscriptnativebridge.message.RequestMessage;
import com.google.code.actionscriptnativebridge.message.ResponseMessage;

public class ActionScriptNativeBridge implements MessageListener
{

  public static ActionScriptNativeBridge getInstance()
  {
    return __INSTANCE;
  }

  public void start() throws IOException, ClassNotFoundException
  {

    // Maps the methods
    MethodsMapper.mapNativeMethods();

    __connection.open();

  }

  public Object callActionscriptMethod(String name, Object... arguments) throws IOException
  {

    Object result = null;

    int requestId = __nextRequestId();
    RequestMessage message = new RequestMessage(requestId, name, arguments);

    __connection.sendMessage(message);

    __pendingRequestMap.put(requestId, null);

    while (__pendingRequestMap.get(requestId) == null)
    {
      try
      {
        Thread.sleep(100);
      }
      catch (InterruptedException e)
      {
        e.printStackTrace();
      }
    }

    Object object = __pendingRequestMap.get(requestId);

    if (object instanceof ResponseMessage)
    {
      ResponseMessage responseMessage = (ResponseMessage) object;
      if (responseMessage.getStatusCode() == StatusCodes.SUCCESS)
      {
        result = responseMessage.getData();
      }
      else
      {
        throw new RuntimeException("Actionscript Error: " + responseMessage.getData());
      }
    }

    return result;
  }

  // @Override
  public void messageReceived(Message message)
  {
    switch (message.getType())
    {

      case REQUEST:

        __processRequestMessage(message);

      break;

      case RESPONSE:

        __processResponseMessage(message);

      break;
    }

  }

  private static final ActionScriptNativeBridge __INSTANCE = new ActionScriptNativeBridge();

  private static int __currentRequestId = 1;

  private Map<Integer, Object> __pendingRequestMap = new HashMap<Integer, Object>();

  private Log __logger = LogFactory.getLog(ActionScriptNativeBridge.class);

  private ActionScriptConnection __connection = new ActionScriptConnection(this);

  private ActionScriptNativeBridge()
  {

  }

  private static synchronized int __nextRequestId()
  {
    return __currentRequestId++;
  }

  private void __processRequestMessage(Message message)
  {

    RequestMessage requestMessage = (RequestMessage) message;
    Message responseMessage = null;

    try
    {
      Object result = __executeOperation(requestMessage.getOperation(), requestMessage.getArguments());
      responseMessage = new ResponseMessage(requestMessage.getRequestId(), StatusCodes.SUCCESS, result);
    }
    catch (Exception e)
    {
      responseMessage = new ResponseMessage(requestMessage.getRequestId(), StatusCodes.FAILURE, e);
    }

    try
    {
      __connection.sendMessage(responseMessage);

      new Thread(new Runnable()
      {

        public void run()
        {
          try
          {
            System.out.println(callActionscriptMethod("soma", 1, 3));
            System.out.println(callActionscriptMethod("multiplica", 2, 3));
            System.out.println("voltou......");
          }
          catch (IOException e)
          {
            // TODO Auto-generated catch block
            e.printStackTrace();
          }

        }

      }).start();

    }
    catch (IOException e)
    {
      e.printStackTrace();
    }

  }

  private void __processResponseMessage(Message message)
  {
    __pendingRequestMap.put(message.getRequestId(), message);
  }

  public Object __executeOperation(String operation, Object[] parameters) throws MethodNotFoundException,
      ExecutionException
  {

    __logger.debug("Executing the operation \"" + operation + "\" with the parameters "
        + ArrayUtils.toString(parameters));

    Object result = null;

    Class<?> declaringClass = null;
    // Gets a existing method.
    Method method = null;

    if (operation.indexOf(GlobalConstraints.METHOD_SEPARATOR) != -1)
    {
      String[] parts = operation.split(GlobalConstraints.METHOD_SEPARATOR);
      String className = parts[0];
      String methodName = parts[1];

      try
      {
        declaringClass = Class.forName(className);

        // Gets argument types.
        List<Class<?>> types = new ArrayList<Class<?>>();
        for (Object argument : parameters)
        {
          types.add(argument.getClass());
        }
        final Class<?> parameterTypes[] = new Class<?>[types.size()];
        types.toArray(parameterTypes);

        method = declaringClass.getMethod(methodName, parameterTypes);
      }
      catch (Exception e)
      {
        __logger.error(e.getMessage());
        e.printStackTrace();
      }
    }
    else
    {
      method = MethodsMapper.getMethod(operation);
      declaringClass = method.getDeclaringClass();
    }

    if (method != null)
    {
      try
      {
        __logger.debug("invoking " + method.getName());

        Object declaringObject = declaringClass.newInstance();

        method.setAccessible(true);
        result = method.invoke(declaringObject, parameters);
      }
      catch (Exception e)
      {
        throw new ExecutionException(e);
      }

    }
    else
    {
      throw new MethodNotFoundException("Unknown method...");
    }

    return result;
  }

}
