module GGLib

Events = enum(
  :focus,
  :blur,
  :activate,
  :deactivate,
  :mouse_down,
  :mouse_up,
  :button_down,
  :button_up,
  :update,
  :draw,
  :damage
)

Events.alias :click, :mouse_up

class EventHandle

  attr_reader :event, :handle_name, :handle_object

  def initialize(event, handle_name, handle_object)
    @event = event
    @handle_name = handle_name
    @handle_object = handle_object
  end

end

# A Publisher is any object that allows objects to subscribe to various events.
module Publisher

  # Subscribe to an event of this publisher. 
  # +event+:: The event to listen to.
  # +handle_name+:: An identifier for the event handler.
  # +modifiers+:: Additional event parameters that must be present for the handler to fire.
  def subscribe(event, handle_name, *modifiers, &handler)
    @events = { } if @events.nil?
    @events[event] = [] if @events[event].nil?
    @events[event].push([handler, modifiers])
    return EventHandle.new(event, handle_name, [handler, modifiers])
  end

  # Similar to subscribe, but without the handle name parameter. A default name of a null string is
  # used instead.
  def on(event, *modifiers, &handler)
    return subscribe(event, '', *modifiers, &handler)
  end

  # Remove the event handle with the given name.  If the event handle was registered without a name
  # (using the on method), then it is impossible to delete it with unsubscribe.
  def unsubscribe(event, handle_name = nil)
    #TODO: implement
    #return @events[event].delete(event.handle_object) if event.kind_of?(EventHandle)
    #return @events[event].delete(handle_name)
  end

  # Publish an event to all of the subscribers to that event.
  # +event+:: The event to publish.
  # +arguments+:: Additional information about the event.
  def publish(event, arguments)
    @events = { } if @events.nil?
    event_handlers = @events[event]
    unless event_handlers.nil?
      event_handlers.each do |handler|
        next if handler[1].size > arguments.size
        call = true
        handler[1].each do |mod|
          unless arguments.index(mod)
            call = false
            break
          end
        end
        handler[0].call(self, *arguments) if call
      end
    end
    return nil
  end

  # Similar to publish, but takes an arbitrary number of extra arguments instead of an array of event
  # information.
  def signal(event, *arguments)
    return publish(event, arguments)
  end

end

end
