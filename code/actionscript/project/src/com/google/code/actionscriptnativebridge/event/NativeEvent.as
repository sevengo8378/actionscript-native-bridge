package com.google.code.actionscriptnativebridge.event
{
  import flash.events.Event;

  public class NativeEvent extends Event
  {
    // --------------------------------------------------------------------------------------------------
    // Public API
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Constructor.
     * 
     */ 
    public function NativeEvent(
      type:String, 
      requestId:int, 
      data:Object = null, 
      bubbles:Boolean = false, 
      cancelable:Boolean = false)
    {
      super(type, bubbles, cancelable);
      __requestId = requestId;
      __data = data;
    }
    
    /**
     * Retrieves the request identifier.
     * 
     * @return The request identifier.
     */
    public function get requestId():int
    {
      return __requestId;
    }
    
    /**
     * Retrieves the event data.
     * 
     * @return The event data.
     */
    public function get data():Object
    {
      return __data;
    }
    
    // --------------------------------------------------------------------------------------------------
    // Protected Members
    // --------------------------------------------------------------------------------------------------
    
    // --------------------------------------------------------------------------------------------------
    // Private Members
    // --------------------------------------------------------------------------------------------------
    
    /**
     * Request identifier related to this event.
     */
    private var __requestId:int;
    
    /**
     * Event data.
     */
    private var __data:Object;
    
  }
}