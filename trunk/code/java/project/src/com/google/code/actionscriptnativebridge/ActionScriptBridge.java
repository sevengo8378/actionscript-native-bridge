/* ------------------------------------------------------------------------------------------------------
 *
 * File: ActionScriptBridge.as
 *
 *                                             Revision History
 * ------------------------------------------------------------------------------------------------------
 * Author (username)                    Date      CR Number   Comments
 * --------------------------------  ----------  -----------  -------------------------------------------
 * Paulo Coutinho (pcmnac)           2009.04.10               Initial creation.
 * ------------------------------------------------------------------------------------------------------
 */

package com.google.code.actionscriptnativebridge;

import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.code.actionscriptnativebridge.ActionScriptConnection.MessageListener;
import com.google.code.actionscriptnativebridge.annotation.StatefulObject;
import com.google.code.actionscriptnativebridge.exception.ExecutionException;
import com.google.code.actionscriptnativebridge.exception.MethodNotFoundException;
import com.google.code.actionscriptnativebridge.message.Message;
import com.google.code.actionscriptnativebridge.message.RequestMessage;
import com.google.code.actionscriptnativebridge.message.ResponseMessage;

/**
 * ActionScript Bridge interface. Use this class to make calls to ActionScript methods and listen for
 * ActionScript calls.
 * 
 * @author <a href="mailto:pcmnac@gmail.com">pcmnac++</a>.
 * 
 */
public class ActionScriptBridge implements MessageListener
{

  /**
   * Retrieves the unique instance of {@link ActionScriptBridge} class.
   * 
   * @return The unique instance of {@link ActionScriptBridge} class.
   */
  public static ActionScriptBridge getInstance()
  {
    return __INSTANCE;
  }

  /**
   * Starts bridge communication.
   * 
   * @throws IOException
   *           If an error occurs during the file scanning process or the connection.
   */
  public void start() throws IOException
  {
    // Maps the methods
    MethodsMapper.mapNativeMethods();

    __connection.open();
  }

  /**
   * Makes a call to an ActionScript method.
   * 
   * @param objectId
   *          The ID of the object where the method will be called.
   * @param name
   *          The name of the requested method.
   * @param arguments
   *          The arguments to be passed to the ActionScript method.
   * 
   * @return The method's result.
   * 
   * @throws IOException
   *           If an error occurs on the connection.
   */
  public Object callActionscriptMethod(String objectId, String name, Object... arguments)
  {

    Object result = null;

    int requestId = __nextRequestId();
    RequestMessage message = new RequestMessage(requestId, objectId, name, arguments);

    try
    {
      __connection.sendMessage(message);
    }
    catch (Exception e)
    {
      throw new RuntimeException("Error sending message...");
    }

    __pendingRequestMap.put(requestId, null);

    while (__pendingRequestMap.get(requestId) == null)
    {
      try
      {
        // TODO: make this value configurable.
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

  public void addListener(ActionScriptBridgeListener listener)
  {
    __connection.addListener(listener);
  }

  public void removeListener(ActionScriptBridgeListener listener)
  {
    __connection.removeListener(listener);
  }

  // @Override
  public void messageReceived(Message message)
  {
    switch (message.getType())
    {

      case REQUEST:

        __processRequestMessage((RequestMessage) message);

      break;

      case RESPONSE:

        __processResponseMessage((ResponseMessage) message);

      break;
    }

  }

  private static final ActionScriptBridge __INSTANCE = new ActionScriptBridge();

  private static int __currentRequestId = 1;

  private Map<Integer, Object> __pendingRequestMap = new HashMap<Integer, Object>();

  private Log __logger = LogFactory.getLog(ActionScriptBridge.class);

  private ActionScriptConnection __connection = new ActionScriptConnection(this);

  private Map<String, Object> __asObjects = new HashMap<String, Object>();

  private ActionScriptBridge()
  {

  }

  private static synchronized int __nextRequestId()
  {
    return __currentRequestId++;
  }

  private void __processRequestMessage(RequestMessage requestMessage)
  {
    ResponseMessage responseMessage = null;

    try
    {
      Object target = __getTargetObject(requestMessage);

      String methodName = requestMessage.getOperation();
      Object[] arguments = requestMessage.getArguments();

      if (requestMessage.getObjectId() == null)
      {
        Method method = MethodsMapper.getMethod(requestMessage.getOperation());
        methodName = method.getName();
      }

      Object result = __invokeOperation(target, methodName, arguments);

      responseMessage = new ResponseMessage(requestMessage.getRequestId(), requestMessage.getObjectId(),
          StatusCodes.SUCCESS, result);
    }
    catch (Exception e)
    {
      responseMessage = new ResponseMessage(requestMessage.getRequestId(), requestMessage.getObjectId(),
          StatusCodes.FAILURE, e);
    }

    try
    {
      __connection.sendMessage(responseMessage);
      System.out.println("rteste,,,,,,");
    }
    catch (IOException e)
    {
      __logger.error("Error sending message", e);
    }

  }

  private void __processResponseMessage(Message message)
  {
    __pendingRequestMap.put(message.getRequestId(), message);
  }

  private Object __getTargetObject(RequestMessage requestMessage)
  {
    Object target = null;
    String objectId = requestMessage.getObjectId();
    Class<?> declaringClass = null;

    if (objectId != null)
    {
      if (__asObjects.containsKey(objectId))
      {
        target = __asObjects.get(objectId);
      }
      else
      {
        try
        {
          declaringClass = Class.forName(objectId);
          target = declaringClass.newInstance();

          StatefulObject annotation = declaringClass.getAnnotation(StatefulObject.class);

          if (annotation != null)
          {
            objectId = UUID.randomUUID().toString();
            __asObjects.put(objectId, target);
          }
          else
          {
            objectId = null;
          }

          requestMessage.setObjectId(objectId);
        }
        catch (Exception e)
        {
          __logger.error("Error getting destination object", e);
          throw new RuntimeException("Target object does not exist or is not available.", e);
        }
      }
    }
    else
    {
      // Uses the facade mode...
      Method method = MethodsMapper.getMethod(requestMessage.getOperation());
      try
      {
        declaringClass = method.getDeclaringClass();
        target = declaringClass.newInstance();
      }
      catch (Exception e)
      {
        __logger.error("Method does not exist or is not available", e);
        throw new RuntimeException("Method does not exist or is not available.", e);
      }
    }

    return target;
  }

  public Object __invokeOperation(Object object, String operation, Object[] parameters)
      throws MethodNotFoundException, ExecutionException
  {
    __logger.debug("Executing the operation \"" + operation + "\" with the parameters "
        + ArrayUtils.toString(parameters));

    Object result = null;

    // Gets a existing method.
    Method method = null;

    if (object != null)
    {
      Class<?> declaringClass = object.getClass();

      // Gets argument types.
      List<Class<?>> types = new ArrayList<Class<?>>();
      for (Object argument : parameters)
      {
        types.add(argument.getClass());
      }

      final Class<?> parameterTypes[] = new Class<?>[types.size()];
      types.toArray(parameterTypes);

      try
      {
        method = declaringClass.getMethod(operation, parameterTypes);
      }
      catch (Exception e)
      {
        __logger.error("Error getting method.", e);
      }
    }

    if (method != null)
    {
      try
      {
        __logger.debug("invoking " + method.getName());
        result = method.invoke(object, parameters);
      }
      catch (Exception e)
      {
        __logger.error("Error invoking " + method.getName(), e);
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
