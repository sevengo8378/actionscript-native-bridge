import java.io.IOException;

import com.google.code.actionscriptnativebridge.ActionScriptBridge;
import com.google.code.actionscriptnativebridge.ActionScriptBridgeListener;
import com.google.code.actionscriptnativebridge.annotation.ActionScriptService;

public class MainTest
{

  public static void main(String[] args) throws IOException,
      ClassNotFoundException
  {

    try
    {

      final ActionScriptBridge bridge = ActionScriptBridge.getInstance();

      bridge.addListener(new ActionScriptBridgeListener()
      {

        @Override
        public void bridgeClosed()
        {
          System.out.println("Bridge Closed");
        }

        @Override
        public void bridgeError(Exception e)
        {
          System.out.println("Bridge Error: " + e.getMessage());
        }

        @Override
        public void bridgeOpened()
        {
          System.out.println("Bridge Opened");
        }

        @Override
        public void clientConnected()
        {
          System.out.println("Client Connected");
          
          new Thread(new Runnable()
          {

            public void run()
            {
              try
              {
                System.out.println(bridge.callActionscriptMethod("sum", 1, 3));
                System.out.println(bridge.callActionscriptMethod("mult", 2, 3));
                System.out.println("Ok....");
              }
              catch (IOException e)
              {
                e.printStackTrace();
              }

            }

          }).start();
        }

        @Override
        public void clientDisconnected()
        {
          System.out.println("Client Disconnected");
        }
      });

      bridge.start();

      // JsonMessageTranslator translator = new JsonMessageTranslator();
      //
      // System.out.println("==============================================");
      //
      // System.out.println();
      //
      // String[] requestExamples = {
      // "{\"type\":\"request\",\"requestId\": 1,\"operation\":\"sum\",\"arguments\": [2, 4]}",
      // "{\"type\":\"request\",\"requestId\": 1,\"operation\":\"multiplica\",\"arguments\": [2, 4]}",
      // "{\"type\":\"request\",\"requestId\": 2,\"operation\":\"processa\",\"arguments\": [0, \"pcmnac\"]}"
      // };
      //
      // for (String request : requestExamples)
      // {
      // RequestMessage message = (RequestMessage)
      // translator.messageFromString(request);
      //
      // ActionScriptBridge.getInstance().__executeOperation(message.getOperation(),
      // message.getParameters());
      //
      // System.out.println();
      // }

    }
    catch (Exception e)
    {
      // TODO Auto-generated catch block
      e.printStackTrace();
    }

  }

}

@ActionScriptService
class MyClass
{

}
