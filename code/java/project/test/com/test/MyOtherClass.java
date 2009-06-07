package com.test;

import com.google.code.actionscriptnativebridge.annotation.ActionScriptMethod;
import com.google.code.actionscriptnativebridge.annotation.ActionScriptService;

@ActionScriptService
public class MyOtherClass
{

  @ActionScriptMethod
  public int sum(int a, int b)
  {
    return a + b;
  }

  @ActionScriptMethod(name = "multiplica")
  public int mult(int a, int b)
  {
    return a * b;
  }

  @ActionScriptMethod
  public void processa(Integer i, String name)
  {
    System.out.println(name + " - " + i);
  }

}
