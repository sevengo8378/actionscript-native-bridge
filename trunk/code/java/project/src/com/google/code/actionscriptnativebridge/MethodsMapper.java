package com.google.code.actionscriptnativebridge;

import java.io.IOException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.scannotation.AnnotationDB;
import org.scannotation.ClasspathUrlFinder;

import com.google.code.actionscriptnativebridge.annotation.ActionScriptMethod;
import com.google.code.actionscriptnativebridge.annotation.ActionScriptService;

public class MethodsMapper
{

  /**
   * Scans the classes on the classpath to find the classes annotated with
   * {@link ActionScriptService} and methods annotated with
   * {@link ActionScriptMethod}.
   * 
   * @throws IOException
   *           If an error occurs during the file scanning process.
   */
  public static void mapNativeMethods() throws IOException

  {
    __logger.info("Mapping native methods...");
    // scan java.class.path
    URL[] urls = ClasspathUrlFinder.findClassPaths();
    AnnotationDB db = new AnnotationDB();

    db.scanArchives(urls);

    Set<String> annotatedClasses = db.getAnnotationIndex().get(
        ActionScriptService.class.getName());

    if (annotatedClasses != null && annotatedClasses.size() > 0)
    {
      for (String className : annotatedClasses)
      {
        try
        {
          __logger.debug("New Class Found: " + className);
          Class<?> clazz = Class.forName(className);

          __logger.debug("Class methods:");
          for (Method method : clazz.getMethods())
          {
            ActionScriptMethod actionScriptMethod = method
                .getAnnotation(ActionScriptMethod.class);
            if (actionScriptMethod != null)
            {
              __logger.debug(method.getName() + "(" + actionScriptMethod.name()
                  + ")");
              String key = (!actionScriptMethod.name().equals("")) ? actionScriptMethod
                  .name()
                  : method.getName();
              __methodsMap.put(key, method);

            }
          }
        }
        catch (ClassNotFoundException e)
        {
          __logger.error("Error parsing the class", e);
        }
      }
    }
    else
    {
      __logger.info("No annotated classes were found...");
    }

  }

  /**
   * Retrieves a method based on the given name (key).
   * 
   * @param name
   *          The method name.
   * 
   * @return The corresponding method or <code>null</code>.
   */
  public static Method getMethod(String name)
  {
    return __methodsMap.get(name);
  }

  /**
   * Retrieves a method based on the given name (key).
   * 
   * @param name
   * @param arguments
   * @return
   */
  public static Method getMethod(String name, Object[] arguments)
  {
    return __methodsMap.get(name);
  }

  /**
   * Map with methods available in ActionScript.
   */
  private static Map<String, Method> __methodsMap = new HashMap<String, Method>();

  /**
   * Logger for this class.
   */
  private static Log __logger = LogFactory.getLog(MethodsMapper.class);

}
