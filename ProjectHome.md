# ActionScript Native Bridge #


## Main Objective: ##

---


Provide a transparent way to extend ActionScript (Flash, Flex, AIR) desktop applications capabilities using technologies with native capabilities (Java, C#, C++, Python, etc). On the other hand, provides a easy way to create rich GUIs for existing desktop applications, built with any of these technologies.

## The problem: ##

---


Actionscript based applications usually have an attractive appearance and several graphic features. They also are relatively simple to construct. But they are limited by the flash player sandbox for security reasons. Therefore, several low level features (e.g. OS integration, shell commands and other) are not available on this kind of application.

Technologies like Java and C++ have a lot of capabilities for data manipulation, peripherals handling, OS integration and more. But they don't offers an efficient and productive way to build rich GUIs.

## Objectives: ##

---

  * Design a simple communication protocol (RPC-based) for allowing message exchanging between ActionScript and Native code.
  * Develop a framework to implement the above protocol in the actionscript side.
  * Develop Native side frameworks to implement the protocol (Starting with Java technology).
  * Develop tools for helping development and deployment processes.
  * Design a basic architecture for this kind of application.
  * Develop a base infra-structure layer for allowing the construction of native libraries (e.g. File System, Registry, USB, Bluetooth, etc) using this infra-structure.

## The Protocol ##

### Key points: ###

---

  * Use JSON as the message format; (make the format pluggable for allowing to use other ones, such as XML and AMF)
  * Use identifiers in each sent message to allow asynchronous responses;
  * Send one request or response per message;
  * Messages must be delimited by a null byte (0);

### The ActionScript Framework ###

Key points:

---

  * Communicate through a local socket connection;
  * Use proxies to make native calls transparent for the user;
  * Provides a facade-based way to call native methods;
  * Provides a proxy-based way to call native methods;
  * Allow the creation of stateful object mirrors in both sides;
  * Result and Fault callbacks must can be passed directly as method arguments, it must be detected automatically and handled by the framework;

Example of usage (making requests using the facade-based way):

---

```
// MyClass.as
class MyClass {
  ...
  public function handleButtonClick():void {
    // See that runApplication() method is a dynamic method. 
    // It isn't, and don't have to be, declared at NativeInterface class.
    NativeInterface.instance.runApplication("application path"); 
  }
}
```

Example of usage (making requests using the proxy-based way):

---

```
// System.as
package com.test.native{
  public dynamic class System extends NativeObject {
  }
}

// MyClass.as
import com.test.System;

package {
  class MyClass {
    ...
    public function handleButtonClick():void {
      var system:System = new System();

      // In this case, is expected that exist a class 'System' (with same package/namespace) in the native side, 
      // containing a method called 'runApplication' without arguments.
      system.runApplication("applicationPath"); 
    }
  }
}
```

Example of usage (responding native requests synchronously):

---

```

// MyClass.as
import com.test.System;

package {
  class MyClass {
    ...
    private function __init():void {
      NativeBridge.instance.addHandler(
        "concat",
        function(a:String, b:String):String {
          return a + b; // Return is automatically sent back to native application.
        }
      ); 
    }
  }
}
```

Example of usage (responding native requests asynchronously):

---

```

// MyClass.as
import com.test.System;

package {
  class MyClass {
    ...
    private function __init():void {
      NativeBridge.instance.addAsynchronousHandler(
        "concat",
        function(a:String, b:String, e:NativeRequestEvent):void {
          // You can make any async call...
          myAsyncFunc(
            function():void { // the callback
              e.resultData = a + b;
              // In this way, you have to call sendResponse() method.
              e.sendResponse(); 
            }
          );
        }
      ); 
    }
  }
}
```


### The Java Framework ###

Key points:

---

  * Use annotations and bytecode processing to export Java methods to the AIR side (EJB3 webservice way);
  * Use reflection to forward the proxy-based requests to correspondent classes.

Example of usage:

---


ActionScript > Java communication
```
// MyClass.java
@ActionScriptService
public class MyClass {
  @ActionScriptMethod // Makes this method available in ActionScript code.
  public double getCpuTemperature() {
    double temperature = 0;
    ...
    return temperature;
  }
}
```

```
// MyClass.as
class MyClass {
  public function printCpuTemperature():void {
    // See that getCpuTemperature() method is a dynamic method. 
    // It isn't, and don't have to be, declared at NativeInterface class.
    var temp:Number = NativeInterface.instance.getCpuTemperature(
        // success callback
        new ResultCallback(
          function(result:Number):void {          
            trace("CPU Temperature is: " + temp);
          }
        )
      ); 
  }
}
```

Java > ActionScript communication

```
// MyClass.java
public class MyClass {
  public void printUiPosition() {
    Map point = NativeInterface.call(
        "getUiPosition", // operation
        null // parameters
      );
    System.out.println("UI position (" + point.get("x") + "," + point.get("y") + ")");
  }
}
```

```
// MyClass.as
class MyClass {
  private void myInitFunction():void {
    NativeInterface.instance.addHandler(
        "getUiPosition",
        function () { // The function can take arguments.
          var point = new Object();
          point.x = 0;
          point.y = 0;

          // Result is automatically sent to native application
          return point;
        }
      );
  }
}
```

Related Projects:

---

  * Artemis (http://artemis.effectiveui.com/) (Dead)
  * Merapi (http://merapiproject.net/) (potential partner)
  * CommandProxy (http://code.google.com/p/commandproxy/) (.NET)





