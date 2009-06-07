package com.google.code.actionscriptnativebridge;

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;

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
    __listener = listener;
    __translator = translator;
  }

  public void open() throws IOException
  {
    __logger.info("Opening connection at port " + __port + " ...");
    __server = new ServerSocket(__port);

    __logger.debug("Starting server thread...");
    new Thread(this).start();

  }

  public void sendMessage(Message message) throws IOException
  {
    String messageString = __translator.stringFromMessage(message) + "\u0000";

    __logger.debug("Message sent: " + messageString);

    __output.write(messageString.getBytes());

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
            __listener.messageReceived(message);
          }
        }

      }

    }
    catch (EOFException e)
    {
      __running = false;

      __logger.error("Connection closed.");
    }
    catch (Exception e)
    {
      // TODO: handle exception
      e.printStackTrace();
    }
  }

  private Log __logger = LogFactory.getLog(ActionScriptConnection.class);

  private MessageListener __listener;

  private JsonMessageTranslator __translator;

  private int __port = GlobalConstraints.DEFAULT_PORT;

  private ServerSocket __server;

  private Socket __client;

  private InputStream __input;

  private OutputStream __output;

  private boolean __running;

  private String __readMessage(InputStream stream) throws IOException
  {

    StringBuffer buffer = new StringBuffer();
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
        buffer.appendCodePoint(codePoint);
      }
    }
    while (!zeroByteRead);

    String result = buffer.toString();

    return result;
  }

}
