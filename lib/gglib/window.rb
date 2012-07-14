module GGLib

module MainWindow
  include Container

  attr_accessor :state
  attr_reader :backend, :cursor
  attr_reader :focused_widget, :active_widget
  attr_reader :dragged_widget

  def initialize(backend, state)
    @backend = backend
    @window_visible = false

    @state = state

    @focused_widget = self
    @active_widget = self
    @dragged_widget = nil

    @cursor = Cursor.new(self)

    super()

    @parent = self
    @window = self

    @throttle_render = false

    @x1 = 0
    @y1 = 0
    @x2 = @backend.window_width
    @y2 = @backend.window_height
  end

  def visible=(value) #:nodoc: (This is an attribute)
    if value
      @backend.show_window
    else
      @backend.hide_window
    end
    return super
  end

  def hidden=(value) #:nodoc: (This is an attribute)
    unless value
      @backend.show_window
    else
      @backend.hide_window
    end
    return super
  end

  def hide
    @backend.hide_window
    return super
  end

  def show
    @backend.show_window
    return super
  end

  def close
    return @backend.close_window
  end

  def on_button_down(button) #:nodoc: (This is an implementation detail)

  end

  def on_button_up(button) #:nodoc: (This is an implementation detail)

  end

  private
  #
  # Check which widget has focus in this update cycle.  This will update the attribute focused_widget.
  #
  def check_focus
    old_focused = @focused_widget
    container = self # The MainWindow is the top level Container.
    new_focused = self # The MainWindow gets focus by default if no other Widget has focus.
    widgets = @children
    loop do
      # The focused Widget is the Widget that has a cursor over it. Begin by searching for a  Widget that is the child of the
      # current Container and has the cursor over it.
      widgets.each do |widget|
        if @cursor.enabled? and @cursor.over?(widget) and widget.enabled? and widget.z >= new_focused.z
          new_focused = widget
        end
      end
      if new_focused == container
        # container is the focused Widget. Stop the search.
        break
      elsif new_focused.kind_of?(CompoundWidget) and container == new_focused.container
        # new_focused (the CompoundWidget) is the focused Widget. Stop the search.
        break
      elsif new_focused.kind_of?(Container)
        # If new_focused is a Container, the actual Widget with focus may be new_focused, or it may be one of its descendents.
        # Redo the search for a Widget with the cursor over it, but this time limit the search to the children of new_focused.
        container = new_focused
        widgets = container.children
      elsif new_focused.kind_of?(CompoundWidget)
        # If new_focused is a CompoundWidget, the actual Widget with focus may be new_focused, or it may be one of its
        # descendents. Redo the search for a Widget with the cursor over it, but this time limit the search to the children of
        # new_focused. Since a CompoundWidget is not a Container, the Container for the new search will be the internal
        # Container of the CompoundWidget
        container = new_focused.container
        widgets = container.children
      elsif new_focused == old_focused
        # Focus has not shifted. since the last update cycle. Stop the search.
        break
      else
        # If no Widget amongst the children of the current Container has focus, then the Container (currently pointed to by
        # new_focused) is the focused Widget, so stop the search.
        break
      end
    end
    new_focused.focus unless new_focused == old_focused
    return new_focused
  end

  public
  def update
    @cursor.x = @backend.mouse_x
    @cursor.y = @backend.mouse_y
    check_focus
    return super
  end

  def draw
    x = super
    @cursor.draw
    return x
  end

  def set_focused_widget(widget) #:nodoc: (This is an implementation detail)
    @focused_widget.notify_blur
    widget.notify_focus
    @focused_widget = widget
  end

  def set_active_widget(widget) #:nodoc: (This is an implementation detail)
    @active_widget.notify_deactivate
    widget.notify_activate
    @active_widget = widget
  end

  def set_dragged_widget(widget) #:nodoc: (This is an implementation detail)
    until widget.nil?
      if widget.draggable? or widget.kind_of?(MainWindow)
        break
      else
        widget = widget.parent
      end
    end
    return (@dragged_widget = widget)
  end
end

end #module GGLib
