import java.io.IOException;
import java.util.Map;

import net.sf.json.JSONObject;

import com.google.code.actionscriptnativebridge.ActionscriptNativeBridge;
import com.google.code.actionscriptnativebridge.annotation.NativeService;

public class MainTest
{

  public static void main(String[] args) throws IOException, ClassNotFoundException
  {

    try
    {

      ActionscriptNativeBridge.getInstance().start();

      // JsonMessageTranslator translator = new JsonMessageTranslator();
      //
      // System.out.println("==============================================");
      //
      // System.out.println();
      //
      // String[] requestExamples = {
      // "{\"type\":\"request\",\"requestId\": 1,\"operation\":\"sum\",\"arguments\": [2, 4]}",
      // "{\"type\":\"request\",\"requestId\": 1,\"operation\":\"multiplica\",\"arguments\": [2, 4]}",
      // "{\"type\":\"request\",\"requestId\": 2,\"operation\":\"processa\",\"arguments\": [0, \"pcmnac\"]}" };
      //
      // for (String request : requestExamples)
      // {
      // RequestMessage message = (RequestMessage) translator.messageFromString(request);
      //
      // ActionscriptNativeBridge.getInstance().__executeOperation(message.getOperation(),
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

  public static Map<String, Object> JsonObjectToMap(JSONObject object)
  {
    return null;
  }
}

@NativeService
class MyClass
{

}
