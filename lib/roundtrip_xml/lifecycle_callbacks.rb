module LifecycleCallbacks

  def initialize
    @callbacks = {}
  end
  def on (event, &callback)
    callbacks[event] ||= []
    callbacks[event] << callback
  end

  private
  attr_accessor :callbacks
  def trigger(event, *args)
    @callbacks ||= {}
    callbacks[event] && callbacks[event].each {|cb| cb.call *args}
  end
end