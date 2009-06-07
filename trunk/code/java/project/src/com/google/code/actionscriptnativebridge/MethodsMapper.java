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

  public static void mapNativeMethods() throws IOException, ClassNotFoundException
  {
    __logger.info("Mapping native methods...");
    // scan java.class.path
    URL[] urls = ClasspathUrlFinder.findClassPaths();
    AnnotationDB db = new AnnotationDB();

    db.scanArchives(urls);

    Set<String> annotatedClasses = db.getAnnotationIndex().get(ActionScriptService.class.getName());

    if (annotatedClasses != null && annotatedClasses.size() > 0)
    {
      for (String className : annotatedClasses)
      {
        __logger.debug("New Class Found: " + className);
        Class<?> clazz = Class.forName(className);

        __logger.debug("Class methods:");
        for (Method method : clazz.getMethods())
        {
          ActionScriptMethod actionScriptMethod = method.getAnnotation(ActionScriptMethod.class);
          if (actionScriptMethod != null)
          {
            __logger.debug(method.getName() + "(" + actionScriptMethod.name() + ")");
            String key = (!actionScriptMethod.name().equals("")) ? actionScriptMethod.name() : method.getName();
            __methodsMap.put(key, method);

          }
        }
      }
    }
    else
    {
      System.out.println("No annotated classes....");
    }

  }

  public static Method getMethod(String name)
  {
    return __methodsMap.get(name);
  }

  public static Method getMethod(String name, Object[] arguments)
  {
    return __methodsMap.get(name);
  }

  private static Map<String, Method> __methodsMap = new HashMap<String, Method>();

  private static Log __logger = LogFactory.getLog(MethodsMapper.class);

}
