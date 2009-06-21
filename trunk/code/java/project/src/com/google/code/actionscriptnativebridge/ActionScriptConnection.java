package com.google.code.actionscriptnativebridge;

import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.code.actionscriptnativebridge.message.Message;
import com.google.code.actionscriptnativebridge.translator.JsonMessageTranslator;

public class ActionScriptConnection implements Runnable
{

  public static interface MessageListener
  {
    void messageReceived(Message message);
  }

  public ActionScriptConnection(MessageListener listener)
  {
    this(listener, new JsonMessageTranslator());
  }

  public ActionScriptConnection(MessageListener listener, JsonMessageTranslator translator)
  {
    __messageListener = listener;
    __translator = translator;
  }

  public void open() throws IOException
  {
    __logger.info("Opening connection at port " + Configuration.port + " ...");
    __server = new ServerSocket(Configuration.port);

    // TODO: implement a generic method for this purpose
    // Notify listeners
    for (ActionScriptBridgeListener listener : __bridgeListeners)
    {
      try
      {
        listener.bridgeOpened();
      }
      catch (Exception e)
      {
        __logger.error("Error calling listener", e);
      }
    }

    __logger.debug("Starting server thread...");
    new Thread(this).start();

  }

  public void sendMessage(Message message) throws IOException
  {
    String messageString = __translator.stringFromMessage(message) + "\u0000";

    __logger.debug("Message sent: " + messageString);

    __output.write(messageString.getBytes(Configuration.charset));

    __output.flush();
  }

  public void run()
  {
    try
    {
      __running = true;

      while (__running)
      {
        __logger.info("Waiting for client...");
        __client = __server.accept();

        if (__logger.isInfoEnabled())
        {
          __logger.info("Client connected: " + __client.getRemoteSocketAddress());
        }

        // TODO: implement a generic method for this purpose
        // Notify listeners
        for (ActionScriptBridgeListener listener : __bridgeListeners)
        {
          try
          {
            listener.clientConnected();
          }
          catch (Exception e)
          {
            __logger.error("Error calling listener", e);
          }
        }

        __input = __client.getInputStream();
        __output = __client.getOutputStream();

        while (true)
        {
          // Read a message from Actionscript side.
          __logger.debug("Waiting for client message...");
          String messageString = __readMessage(__input);

          // Creates a new Message object.
          __logger.debug("Message received: " + messageString);
          Message message = __translator.messageFromString(messageString);

          if (message != null)
          {
            // Notifies the listener method.
            __messageListener.messageReceived(message);
          }
        }

      }

    }
    catch (EOFException e)
    {

      __logger.info("Connection closed.");

      // TODO: implement a generic method for this purpose
      // Notify listeners
      for (ActionScriptBridgeListener listener : __bridgeListeners)
      {
        try
        {
          listener.clientDisconnected();
        }
        catch (Exception e1)
        {
          __logger.error("Error calling listener", e1);
        }
      }

      __running = false;

      // TODO: implement a generic method for this purpose
      // Notify listeners
      for (ActionScriptBridgeListener listener : __bridgeListeners)
      {
        try
        {
          listener.bridgeClosed();
        }
        catch (Exception e1)
        {
          __logger.error("Error calling listener", e1);
        }
      }

    }
    catch (Exception e)
    {
      // TODO: handle exception
      __logger.error("Connection error", e);

      // TODO: implement a generic method for this purpose
      // Notify listeners
      for (ActionScriptBridgeListener listener : __bridgeListeners)
      {
        try
        {
          listener.bridgeError(e);
        }
        catch (Exception e1)
        {
          __logger.error("Error calling listener", e1);
        }
      }
    }
  }

  public void addListener(ActionScriptBridgeListener listener)
  {
    __bridgeListeners.add(listener);
  }

  public void removeListener(ActionScriptBridgeListener listener)
  {
    __bridgeListeners.remove(listener);
  }

  private List<ActionScriptBridgeListener> __bridgeListeners = new ArrayList<ActionScriptBridgeListener>();

  private Log __logger = LogFactory.getLog(ActionScriptConnection.class);

  private MessageListener __messageListener;

  private JsonMessageTranslator __translator;

  private ServerSocket __server;

  private Socket __client;

  private InputStream __input;

  private OutputStream __output;

  private boolean __running;

  private String __readMessage(InputStream stream) throws IOException
  {

    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
    int codePoint;
    boolean zeroByteRead = false;

    __logger.debug("Reading...");

    do
    {
      codePoint = stream.read();

      if (codePoint == -1)
      {
        throw new EOFException();
      }
      if (codePoint == 0)
      {
        zeroByteRead = true;
      }
      else
      {
        buffer.write(codePoint);
      }
    }
    while (!zeroByteRead);

    return new String(buffer.toByteArray(), Configuration.charset);
  }

}
