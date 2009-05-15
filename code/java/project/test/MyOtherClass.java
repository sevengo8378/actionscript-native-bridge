import com.google.code.actionscriptnativebridge.annotation.NativeMethod;
import com.google.code.actionscriptnativebridge.annotation.NativeService;

@NativeService
public class MyOtherClass
{

  @NativeMethod
  public int sum(int a, int b)
  {
    return a + b;
  }

  @NativeMethod(name = "multiplica")
  public int mult(int a, int b)
  {
    return a * b;
  }

  @NativeMethod
  public void processa(int i, String name)
  {
    System.out.println(name + " - " + i);
  }

}
