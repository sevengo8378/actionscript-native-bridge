package com.test;

import com.google.code.actionscriptnativebridge.annotation.ActionScriptMethod;
import com.google.code.actionscriptnativebridge.annotation.ActionScriptService;

@ActionScriptService
public class MyOtherClass
{

  @ActionScriptMethod
  public int sum(Integer a, Integer b)
  {
    return a + b;
  }

  @ActionScriptMethod(name = "multiply")
  public int mult(Integer a, Integer b)
  {
    return a * b;
  }

  @ActionScriptMethod
  public void process(Integer i, String name)
  {
    System.out.println(name + " - " + i);
  }

}
