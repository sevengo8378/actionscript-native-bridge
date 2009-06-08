package com.google.code.actionscriptnativebridge;

public interface ActionScriptBridgeListener
{
  void bridgeOpened();
  
  void clientConnected();
  
  void clientDisconnected();
  
  void bridgeError(Exception e);
  
  void bridgeClosed();
}
