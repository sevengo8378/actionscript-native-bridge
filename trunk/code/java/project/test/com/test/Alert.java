package com.test;

import javax.swing.JOptionPane;

import com.google.code.actionscriptnativebridge.annotation.StatefulObject;

@StatefulObject
public class Alert
{
  String message = "";

  public void show(String msg)
  {
    message += "-" + msg;

    JOptionPane.showMessageDialog(null, message);
  }
}
