module GGLib

module Widget

  include Publisher
  include Volatile
  include MetadataStore

  #
  # @!attribute [rw] x
  #   The x-coordinate of the top left corner of the widget. This is the same value as #x1.
  #   Unlike modifying the value of #x1, modifying the value of #x
  #   will move the Widget along the x-axis while preserving the #height and #width.
  #   @return [Fixnum] The x-coordinate of the top left corner of the widget.
  #
  attr_accessor :x

  #
  # @!attribute [rw] y
  #   The y-coordinate of the top left corner of the widget. This is the same value as #y2.
  #   Unlike modifying the value of #y1, modifying the value of #y
  #   will move the Widget along the y-axis while preserving the #height and #width.
  #   @return [Fixnum] The y-coordinate of the top left corner of the widget.
  #
  attr_accessor :y

  #
  # @!attribute [rw] x1
  #   The x-coordinate of the top left corner of the widget. This is the same value as #x.
  #   Note that unlike modifying the value of #x, modifying the value of #x1
  #   will alter the #width of the Widget.
  #   @return [Fixnum] The x-coordinate of the top left corner of the widget.
  attr_accessor :x1

  #
  # @!attribute [rw] y1
  #   The y-coordinate of the top left corner of the widget. This is the same value as #y.
  #   Note that unlike modifying the value of #y, modifying the value of #y1
  #   will alter the #height of the Widget.
  #   @return [Fixnum] The y-coordinate of the top left corner of the widget.
  #
  attr_accessor :y1

  #
  # @!attribute [rw] x2
  #   @return The x-coordinate of the bottom right corner of the widget.
  #
  attr_accessor :x2

  #
  # @!attribute [rw] y2
  #   @return The y-coordinate of the bottom right corner of the widget.
  #
  attr_accessor :y2

  #
  # @!attribute [rw] z
  #   The z-order of the Widget. Widgets with higher z-orders appear above Widgets
  #   with lower z-orders. Widgets with the same z-order will be draw so that those which
  #   were created most recently appear on top.
  #   @return [Fixnum] The z-order of the Widget
  #
  attr_accessor :z

  #
  # @!attribute [rw] width
  #   The #width (x-axis span) of the Widget. Modifying the value of #width will leave #x1 the same, but will modify #x2.
  #   The #width is equal to #x2 - #x1.
  #   @return [Fixnum] The width of the widget.
  #
  attr_accessor :width

  #
  # @!attribute [rw] height
  #   The #height (y-axis span) of the widget. Modifying the value of #width will leave #y1 the same, but will modify #y2.
  #   The #height is equal to #y2 - #y1.
  #   @return [Fixnum] The height of the widget.
  #
  attr_accessor :height

  #
  # @!attribute [rw] auto_size
  #   #auto_size is true if both #auto_size_width and #auto_size_height are true. Setting #auto_size will
  #   set both #auto_size_width and #auto_size_height.
  #   @return [Boolean] True if the widget auto sizes in both dimensions, false otherwise.
  #
  attr_accessor :auto_size

  #
  # @!attribute [rw] auto_size_width
  #   If #auto_size_width is true, the Renderer or the Container will decide the optimal #width for the Widget.
  #   If #auto_size_width is false, the Widget #width must be determined manually.
  #   #auto_size_width is true by default. Setting #width, #x1, or #x2 will set #auto_size_width to false.
  #   @return [Boolean] True if the widget auto sizes along the x-axis, false otherwise.
  #
  attr_accessor :auto_size_width

  #
  # @!attribute [rw] auto_size_height
  #   If #auto_size_height is true, the Renderer or the Container will decide the optimal #height for the Widget.
  #   If #auto_size_height is false, the Widget #height must be determined manually.
  #   #auto_size_height is true by default. Setting #height, #y1, or #y2 will set #auto_size_height to false.
  #   @return [Boolean] True if the widget auto sizes along the y-axis, false otherwise.
  #
  attr_accessor :auto_size_height

  #
  # @!attribute [rw] throttle_render
  #   If #throttle_render is true and MainWindow#throttle_render is true, the Backend will only draw the Widget
  #   when its apprearance is modified in some way. #throttle_render is true by default, but MainWindow#throttle_render
  #   is false by default because the current throttle mechnism tends to cause flicker.
  #   @return [Boolean] True if rendering for this widget is throttled, false otherwise.
  #
  attr_accessor :throttle_render

  #
  # @!attribute [rw] enabled
  #   When #enabled is true, the Widget receives events from the user.
  #   When #enabled is false, the Widget cannot receive user events, but
  #   can continue to receive programmatically generated events.
  #   @return [Boolean] True if this widget is enabled, false otherwise.
  #
  attr_accessor :enabled

  #
  # @!attribute [rw] disabled
  #   The logical opposite of the #enabled attribute.
  #   @return [Boolean] True if this widget is disabled, false otherwise.
  #
  attr_accessor :disabled

  #
  # @!attribute [rw] active
  #   When #active is true, the Widget receives keyboard events from the user.
  #   When #active is false, the Widget does not receive keyboard events, but
  #   continues to receive other events.
  #   A widget can only be activated if #activatable is true.
  #   If activatable is true, then the Widget will be activated when it is #focused
  #   and deactivated when it is blurred.
  #   Only one Widget can be #active at any given time.
  #   @return [Boolean] True if this widget is active, false otherwise.
  #
  attr_accessor :active

  #
  # @!attribute [rw] focused
  #   #focused is true when the cursor is hovering over the Widget.
  #   A #disabled or #hidden Widget cannot receive #focus.
  #   Only one Widget can be #focused at any given time.
  #   @return [Boolean] True if this widget is focused, false otherwise.
  #
  attr_accessor :focused

  #
  # @!attribute [rw] activatable
  #   When #activatable is true, the Widget can be activated. (i.e. #active can be set to true.)
  #   When #activatable is false, the Widget cannot be activated.
  #   If #activatable is true, the Widget will be activated when it is #focused and
  #   deactivated when it is blurred.
  #   @return [Boolean] True if this widget is can be activated, false otherwise.
  #
  attr_accessor :activatable

  #
  # @!attribute [rw] visible
  #   When #visible is true, this Widget and its children are displayed.
  #   When #visible is false, the Widget and its children are not displayed.
  #   @return [Boolean] True if this widget is visible, false otherwise.
  #
  attr_accessor :visible

  #
  # @!attribute [rw] hidden
  #   The logical opposite of the #visible attribute.
  #   @return [Boolean] True if this widget is hidden, false otherwise.
  #
  attr_accessor :hidden

  #
  # @!attribute [rw] text
  #   The #text displayed on the Widget. The way in which the #text is displayed can be controlled by modifying the #style.
  #   @return [String] The text that is displayed on the widget.
  #
  attr_accessor :text

  #
  # @!attribute [rw] style
  #   An instance of WidgetStyle that controls how this Widget is displayed.
  #   @return [WidgetStyle] The style object for this widget.
  #
  attr_accessor :style

  #
  # If #draggable is true, the Widget can be dragged around with the mouse.
  #
  attr_accessor :draggable

  #
  # If #floating is true, the Widget will not be positioned by the Layout of its #parent Container.
  # Instead, the position of the Widget will be determined by setting the #x and #y coordinates manually.
  # If #floating is false, the Layout will choose the position of the Widget.
  #
  attr_accessor :floating

  #
  # @!attribute [rw] label
  #   A Label Widget that is associated with this Widget. When the #label Widget is #focused, it will
  #   forward the #focus to this Widget.
  #   @return [Label] The Label Widget associated with this Widget.
  #
  attr_accessor :label

  #
  # @!attribute [r] parent 
  #   @return [Container] The Container that contains this Widget.
  #
  attr_reader :parent

  #
  # @!attribute [r] window
  #   @return [MainWindow] The MainWindow that is contains this Widget.
  #
  attr_reader :window

  #
  # A hint used by the Renderer to decide how to #draw the Widget. A Button, for example,
  # has a #theme_class of +:button+, hinting that the Renderer should make it appear like a 
  # Button. A Label has a #theme_class of +:invisible+ because it only does not require the Renderer
  # to #draw it a background. (It only needs the Renderer to #draw its #text.) A Scroll Widget
  # has several child Widgets, including the grip and the two buttons. Each of these Widgets has
  # a different #theme_class because they each must be drawn differently.
  # A list of #theme_class values used by GGLib can be found in the documentation for Renderer. 
  # It is possible to extend GGLib to use new #theme_class symbols.
  #
  attr_reader :theme_class

  attr_bool :floating
  attr_bool :auto_size, :auto_size_width, :auto_size_height
  attr_bool :throttle_render, :draggable
  attr_bool :enabled, :disabled, :active, :activatable, :focused, :visible, :hidden

  alias :'needs_redraw?' :damaged

  def theme_class
    return get_field 'theme_class'
  end

  def theme_class=(theme_class_name = nil)
    set_field 'theme_class', theme_class_name
    return nil
  end

  @@default_style = WidgetStyle.new

  def Widget.default_style
    return @@default_style
  end

  def Widget.default_style=(val)
    return @@default_style
  end

  def initialize
    @x1 = @y1 = @x2 = @y2 = @z = 0
    @enabled = true
    @visible = true
    @activatable = true
    @parent = nil
    @window = GGLib::default_window
    @draggable = false
    #@theme_class = @theme_class || :default
    @floating = false
    self.style = @@default_style.dup
    @auto_size_width = true
    @auto_size_height = true
    @throttle_render = true
    @text = ''
    @label = nil
  end

  def auto_size?
    return (@auto_size_width and @auto_size_height)
  end

  def auto_size=(value) # @api private (This is an attribute)
    #signal(:modified, :auto_size) unless value == @auto_size --> not necessary because this value is marked volatile
    #TODO: Good idea to fire a modified signal for auto_size? Possibly necessary for render throttling. What about when auto_size is set to false by using a resizing op?
    @auto_size_width = @auto_size_height = value
    return value
  end

  def x
    return @x1
  end

  def y
    return @y1
  end

  def height
    return @y2 - @y1
  end

  def width
    return @x2 - @x1
  end

  def x=(value)
    w = width
    @x1 = value
    @x2 = @x1 + w
    return (@x1 = value)
  end

  def y=(value)
    h = height
    @y1 = value
    @y2 = @y1 + h
    return (@y1 = value)
  end

  def x1=(value)
    self.auto_size_width = false
    return (@x1 = value)
  end

  def y1=(value)
    self.auto_size_height = false
    return (@y1 = value)
  end

  def x2=(value)
    self.auto_size_width = false
    return (@x2 = value)
  end

  def y2=(value)
    self.auto_size_height = false
    return (@y2 = value)
  end

  def height=(value)
    self.auto_size_height = false
    @y2 = @y1 + value
    return value
  end

  def width=(value)
    self.auto_size_width = false
    @x2 = @x1 + value
    return value
  end

  #
  # Move the Widget to the specified #x, #y, and #z coordinates.
  # If no #z coordinate is given, the #z order will not be changed.
  # @param [Fixnum] x The new x coordinate of the top left corner of the widget
  # @param [Fixnum] y The new y coordinate of the top left corner of the widget
  # @param [Fixnum] z The new z order of the widget. (A larger value means a higher position.)
  # @return [nil]
  #
  def move(x, y, z=@z)
    self.x = x
    self.y = y
    self.z = z
    return nil
  end

  #
  # Set the #width and #height of the Widget.
  # @example
  #   widget.resize(w, h)
  #   # is equivalent to
  #   widget.width = w
  #   widget.height = h
  # @param [Fixnum] width The new width of the widget
  # @param [Fixnum] height The new height of the widget
  # @return [nil]
  #
  def resize(width, height)
    self.width = width
    self.height = height
    return nil
  end

  #
  # Set the coordinates of the top left and bottom right corners of the Widget.
  # @param [Fixnum] x1 The x-coordinate of the top left corner
  # @param [Fixnum] y1 The y-coordinate of the top left corner
  # @param [Fixnum] x2 The x-coordinate of the bottom right corner
  # @param [Fixnum] y2 The y-coordinate of the bottom right corner
  # @return [nil]
  #
  def set_region(x1, y1, x2, y2)
    damage(:region)
    self.auto_size_width = false
    self.auto_size_height = false
    @x1, @y1, @x2, @y2 = x1, y1, x2, y2
    return nil
  end

  def enabled?
    return @enabled
  end

  def disabled?
    return (not @enabled)
  end

  def enabled=(value)
    damage(:enabled) unless value == @enabled
    return (@enabled = value)
  end

  def disabled=(value)
    damage(:enabled) unless (not value) == @enabled
    return (@enabled = (not value))
  end

  #
  # Set #enabled to true.
  # @return [true]
  #
  def enable
    damage(:enabled)
    return (@enabled = true)
  end

  #
  # Set #enabled to false.
  # @return [false]
  #
  def disable
    damage(:enabled)
    return (@enabled = false)
  end

  def active?
    return @window.active_widget == self
  end

  def active=(value)
    if value and @activatable and not active?
      activate
    elsif not value and active?
      deactivate
    end
    return (value and @activatable)
  end

  #
  # Set #active to true.
  # @return [true]
  #
  def activate
    @window.set_active_widget(self) if @activatable and not active?
    return @activatable
  end

  #
  # Set #active to false.
  # @return [false]
  #
  def deactivate
    @window.set_active_widget(@window) if active?
    return false
  end

  def activatable?
    return @activatable
  end

  def activatable=(value)
    return (@activatable = value)
  end

  def focused?
    return @window.focused_widget == self
  end

  #
  # Set #focused to true.
  # @note If the Cursor is currently hovering over another Widget,
  #   #focus will switch back to that Widget in the next update.
  # @return [true]
  #
  def focus
    @window.set_focused_widget(self) unless focused?
    return true
  end

  #
  # Set #focused to false.
  # @note If the Cursor is currently hovering over this Widget,
  #   This widget will be refocused in the next update.
  # @return [false]
  #
  def blur
    @window.set_focused_widget(@window) if focused?
    return false
  end

  # --
  # The following methods are callbacks used by MainWindow.
  # They are not meant for direct use.
  # ++

  # @api private
  def notify_focus
    damage(:focused)
    signal(:focus)
  end

  # @api private
  def notify_blur
    damage(:focused)
    signal(:blur)
  end

  # @api private
  def notify_activate
    damage(:active)
    signal(:activate)
  end

  # @api private
  def notify_deactivate
    damage(:active)
    signal(:deactivate)
  end

  def visible?
    return @visible
  end

  def hidden?
    return (not @visible)
  end

  def visible=(value)
    damage(:visible) unless value == @visible
    return (@visible = value)
  end

  def hidden=(value)
    damage(:visible) unless (not value) == @visible
    return (@visible = (not @value))
  end

  # Set visible to false.
  def hide
    damage(:visible) unless not @visible
    return (@visible = false)
  end

  # Set visible to true.
  def show
    damage(:visible) unless @visible
    return (@visible = true)
  end

  def style=(value)
    value.set_widget(self)
    return (@style = value)
  end

  # @api private
  def set_container(object)
    @parent = object
    @window = object.window
    @style.configure_renderer
    return (@parent == object)
  end

  # @api private
  def unset_container(object)
    if object == @parent
      @parent = nil
      @window = nil
      @style.configure_renderer
      return true
    end
    return false
  end

  def label=(value)
    @label.unset_owner(self) unless @label.nil?
    value.set_owner(self)
    return (@label = value)
  end

  #
  # Cause the Widget to be positioned via absolute coordinates instead of being positioned by its parent's Layout.
  # If the parent's Layout is FreeLayout, then this method will have no effect, as the FreeLayout does not
  # reposition children. Note that Containers do not handle overflow for floating Widgets. A floating widget
  # will appear as if the parent's overflow mode is set to Overflow::SHOW reg
  # @return [nil]
  #
  def float
    @floating = true
    damage(:floating)
    return nil
  end

  #
  # Cause the Widget to be positioned by its parent's Layout.
  # A Widget will be positioned by its parent Container's Layout be default. The snap method should be used to
  # restore the default behavior after a call to float.
  # @return [nil]
  #
  def snap
    @floating = false
    damage(:floating)
    return nil
  end

  #
  # Give the Widget the highest z order in its parent Container. This will cause the Widget to appear on top of any of its overlapping siblings.
  # @return [nil]
  #
  def bring_to_front
    @parent.bring_child_to_front(self)
    return nil
  end

  #
  # Give the Widget the lowest z order in its parent Container. This will cause the Widget to appear underneath any of its overlapping siblings.
  # @return [nil]
  #
  def send_to_back
    @parent.send_child_to_back(self)
    return nil
  end

  def draw
    if @visible
      unless @style.renderer.nil?
        @style.renderer.draw(self) unless (@throttle_render and @window.throttle_render? and not needs_redraw?)
      end
      signal(:draw) unless @events[:draw].nil?
      clear_damage #TODO: only clear damage when visible as is happening now, or also clear damage when hidden?
    end
    return @visible
  end

  def update
    signal(:update) unless @events[:update].nil?
    return nil
  end

  attr_volatile :x, :y, :x1, :y1, :x2, :y2, :z, :width, :height
  attr_volatile :text, :style
  attr_volatile :auto_size, :auto_size_width, :auto_size_height
  attr_volatile :floating
  attr_volatile :label
  #TODO: consider making these volatile
  #attr_volatile :enabled, :disabled, :active, :visible, :hidden

end

end
