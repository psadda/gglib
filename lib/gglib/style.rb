module GGLib

VerticalAlign = enum :top, :middle, :bottom
Align = enum :left, :center, :right
Spacing = enum :none, :flexible
Overflow = enum :auto, :show, :hide, :scroll, :stretch

class Color
  include Volatile

  attr_accessor :alpha, :red, :green, :blue
  attr_volatile :alpha, :red, :green, :blue

  alias :a :alpha
  alias :r :red
  alias :g :green
  alias :b :blue

  alias :'a=' :'alpha='
  alias :'r=' :'red='
  alias :'g=' :'green='
  alias :'b=' :'blue='

  #
  # r1 = g1 = b1 = a1 = 0.5
  # r255 = g255 = b255 = a255 = 127
  #
  # Color.new # White
  # Color.new(r1, b1, g1, a1)
  # Color.new(r255, b255, g255, a255)
  # Color.new( [r255, b255, g255, a255] )
  # Color.new( Color.new(r255, b255, g255, a255) )
  # Color.new( Gosu::Color.new(r255, b255, g255, a255) )
  # Color.new( RubyGame::ColorRGB(r255, b255, g255, a255) )
  #
  # Note: The alpha value is always optional and defaults to full opacity.
  #
  def initialize(color = nil, green=nil, blue=nil, alpha=255)
    super

    if color.nil?
      @alpha = @red = @green = @blue = 255
      return
    end
    if color.kind_of?(Fixnum) and color <=255
      @alpha, @red, @green, @blue = alpha, color, green, blue
      return
    end
    if color.kind_of?(Fixnum)
      @alpha = @red = @green = @blue = 255
      #TODO: fix to actually read the integer
      return
    end
    if color.kind_of?(Array)
      @red, @green, @blue = color[0], color[1], color[2]
      if color.size > 3
        @alpha = color[3]
      else
        @alpha = 255
      end
      return
    end

    @alpha, @red, @green, @blue = alpha, color, green, blue

    #GGLib
    if color.kind_of?(Color)
      @alpha, @red, @green, @blue = color.alpha, color.red, color.green, color.blue
    end

    #Gosu
    begin
      if color.kind_of?(Gosu::Color)
        @alpha, @red, @green, @blue = color.alpha, color.red, color.green, color.blue
      end
    rescue
    end

    #Rubygame
    begin
      if color.kind_of?(RubyGame::Color)
        dat = color.to_rgba_ary
        @alpha, @red, @green, @blue = dat[3], dat[0], dat[1], dat[2]
      end
    rescue
    end
  end

  def initialize_copy(copy)
    super
    @alpha, @red, @green, @blue = copy.alpha, copy.red, copy.green, copy.blue
  end

  def to_rubygame
    return Rubygame::Color::ColorRGB.new([@red, @green, @blue, @alpha])
  end

  def to_gosu
    return Gosu::Color.argb(@alpha, @red, @green, @blue)
  end

  def to_chingu
    return to_gosu
  end
end

#
# Specify top, left, right, and bottom measurements in a CSS-like manner.
#
class FourSidedStyle
  include Volatile

  attr_accessor :top, :left, :right, :bottom
  attr_volatile :top, :left, :right, :bottom

  #
  # If no values are given, all four properties are set to zero.
  # If only one value is given, all four properties are set to that value.
  # If four values are given, each parameter is assigned to the corrosponding property.
  #
  def initialize(top = 0, right = nil, bottom = nil, left = nil)
    super
    if right.nil?
      @top = @right = @bottom = @left = top
    else
      @top, @right, @bottom, @left = top, right, bottom, left
    end
  end

  def initialize_copy(copy)
    super
    @top, @right, @bottom, @left = copy.top, copy.right, copy.bottom, copy.left
  end

  #
  # If only one value is given, all four properties are set to that value.
  # If four values are given, each parameter is assigned to the corrosponding property.
  #
  def set(top, right = nil, bottom = nil, left = nil)
    signal(:modified, :all)
    @top = top
    if right.nil? and bottom.nil? and left.nil?
      @right, @bottom, @left = top
    else
      @right = right unless right.nil?
      @bottom = bottom unless bottom.nil?
      @left = left unless left.nil?
    end
    return nil
  end
end

#
# When a Widget is placed into a container, its Margin determines the minimum space between it and its neighbor. Similar to the CSS concept of margins.
#
class Margin < FourSidedStyle; end

#
# Extra space inserted around the central area of a Widget. This is the area of the Widget where text is drawn, if the Widget has any text. Similar to the CSS concept of padding.
#
class Padding < FourSidedStyle; end

class Font
  include Volatile

  attr_accessor :family, :size, :color

  alias :height :size
  alias :'height=' :'size='

  DEFAULT_FAMILY = 'Verdana'
  DEFAULT_SIZE = 20
  DEFAULT_HEIGHT = DEFAULT_SIZE
  DEFAULT_COLOR = GGLib::Color.new(0, 0, 0)

  def initialize
    super
    @family = DEFAULT_FAMILY.dup
    @size = DEFAULT_SIZE
    self.color = DEFAULT_COLOR.dup
  end

  def initialize_copy(copy)
    super
    #TODO: is freezing a good strategy for text?
    @family = copy.family.dup
    @size = copy.size
    self.color = copy.color.dup
  end

  def color=(val)
    return (@color = GGLib::Color.new(val))
  end

  attr_volatile :family, :size, :color
end

#
# A WidgetStyle determines how a Widget is drawn and how it is layed out within a Container.
#
# Attributes which specify how the Widget is layed out within its parent Container:
# +align+:: Where to position the Widget in a vertical layout
# +vertical_align+:: Where to position the Widget in a horizontal layout
#
# Attributes which specify how the Widget's children are layed out:
# +margin+:: Additional space added between the Widget and its parent or siblings.
# +horizontal_overflow+:: The method for handling overflow along the x-axis for the contents of this Widget.
# +vertical_overflow+:: The method for handling overflow along the y-axis for the contents of this Widget.
#
# Attributes which specify how the Widget's text is layed out:
# +padding+:: Additional space added between the border of the text region of the Widget and the text.
# +line_spacing+:: The number of pixels between lines of text within the Widget.
# +font+:: The Font with which the text is drawn.
#
# Attributes which specify how the Widget is drawn:
# +renderer+:: The Renderer object that is responsible for drawing this Widget.
# +theme+:: The Theme of the Widget. A Theme is a type of Renderer. Setting the theme attribute will also set the renderer attribute.
# +image+:: The image used to draw the Widget. Setting the image attribute sets the renderer to an instance of ImageRenderer.
# +color+:: The Color of the Widget. Setting this property will cause the Widget to be drawn as a rectangle of the specified Color. Setting the color property sets the renderer to an instance of SolidRenderer.
#
class WidgetStyle
  include Volatile

  DEFAULT_LINE_SPACING = 0
  DEFAULT_THEME = nil
  DEFAULT_IMAGE = nil
  DEFAULT_COLOR = nil
  DEFAULT_RENDERER = nil
  DEFAULT_ALIGN = Align::CENTER
  DEFAULT_VERTICAL_ALIGN = VerticalAlign::MIDDLE
  DEFAULT_HORIZONTAL_OVERFLOW = Overflow::AUTO
  DEFAULT_VERTICAL_OVERFLOW = Overflow::AUTO
  DEFAULT_PADDING = Padding.new
  DEFAULT_MARGIN = Margin.new(5)
  DEFAULT_FONT = Font.new

  attr_accessor :vertical_align, :align, :horizontal_overflow, :vertical_overflow
  attr_accessor :padding, :margin, :font, :line_spacing
  attr_accessor :renderer, :theme, :image, :color

  def initialize
    super
    @widget = nil
    self.padding = DEFAULT_PADDING.dup
    self.margin = DEFAULT_MARGIN.dup
    self.font = DEFAULT_FONT.dup
    @align = DEFAULT_ALIGN
    @vertical_align = DEFAULT_VERTICAL_ALIGN
    @horizontal_overflow = DEFAULT_HORIZONTAL_OVERFLOW
    @vertical_overflow = DEFAULT_VERTICAL_OVERFLOW
    @line_spacing = DEFAULT_LINE_SPACING
    @image = nil
    @color = nil
    @renderer = nil
    @theme = DEFAULT_THEME # Not really applying a theme, but remembering it for later when a widget takes ownership
  end

  def initialize_copy(copy)
    super
    @widget = nil
    @padding = copy.padding.dup
    @margin = copy.margin.dup
    @font = copy.font.dup
    @align = copy.align
    @vertical_align = copy.vertical_align
    @horizontal_overflow = copy.horizontal_overflow
    @vertical_overflow = copy.vertical_overflow
    @line_spacing = copy.line_spacing
    @image = @color = nil
    @image = copy.image.dup unless copy.image.nil?
    @color = copy.color.dup unless copy.color.nil?
    @theme = copy.theme # Not really applying a theme, but remembering it for later when a widget takes ownership
    unless copy.renderer.nil?
      self.renderer = copy.renderer.dup
    else
      @renderer = nil
    end
  end

  private
  def set_renderer(value)
    @renderer.unsubscribe(:modified, self.object_id) if @renderer.kind_of?(Volatile)
    signal(:modified, :renderer)
    @renderer = value
    return nil if @renderer.nil?
    @renderer.subscribe(:modified, self.object_id) do
      signal(:modified, :renderer)
    end
    configure_renderer
    return @renderer
  end

  def unset_theme
    @theme.unsubscribe(:modified, self.object_id) if @theme.kind_of?(Volatile)
    signal(:modified, :theme)
    @theme = nil
  end

  def unset_image
    @image.unsubscribe(:modified, self.object_id) if @image.kind_of?(Volatile)
    signal(:modified, :image)
    @image = nil
  end

  def unset_color
    @color.unsubscribe(:modified, self.object_id) if @color.kind_of?(Volatile)
    signal(:modified, :color)
    @color = nil
  end

  public
  def renderer=(value)
    unset_theme
    unset_image
    unset_color
    return set_renderer(value)
  end

  def theme=(value)
    unset_image
    unset_color
    set_renderer(value.renderer_for(@widget)) unless @widget.nil?
    return (@theme = value)
  end

  def image=(value)
    unset_theme
    unset_color
    @image = value
    renderer = ImageRenderer.new(value)
    renderer.auto_size = true
    return set_renderer(renderer)
  end

  def color=(value)
    unset_theme
    unset_image
    @color = GGLib::Color.new(value)
    return set_renderer(SolidRenderer.new(@color))
  end

  def configure_renderer #:nodoc: (This is an implementation detail.)
    unless @widget.nil? or @renderer.nil?
      unless @widget.window.nil?
        @renderer.backend = @widget.window.backend
      else
        @renderer.backend = nil
      end
      @widget.unreported do
        if @widget.auto_size_width?
          @widget.width = @renderer.suggested_width(@widget)
          @widget.auto_size_width = true
        end
        if @widget.auto_size_height?
          @widget.height = @renderer.suggested_height(@widget)
          @widget.auto_size_height = true
        end
      end
      #TODO: initialize_copy(@renderer.suggested_style(@widget))
    end
  end

  def set_widget(widget) #:nodoc: (This is an implementation detail.)
    @widget = widget
    if not @theme.nil? and @renderer.nil?
      #A theme has already been chosen, and now we must apply it to the new widget
      set_renderer(@theme.renderer_for(@widget))
    end
  end

  attr_volatile :vertical_align, :align, :horizontal_overflow, :vertical_overflow
  attr_volatile :padding, :margin, :font, :line_spacing
  attr_volatile :theme, :image, :color #Leave out renderer because set_renderer takes care of this stuff
end

#
# A ContainerStyle determines how a Container's children are positioned.
#
class ContainerStyle < WidgetStyle
  attr_accessor :spacing, :active_area_padding
  attr_volatile :spacing, :active_area_padding

  DEFAULT_SPACING = Spacing::FLEXIBLE

  def initialize
    super
    @spacing = DEFAULT_SPACING
  end

  def initialize_copy(copy)
    super
    @spacing = copy.spacing
  end

end

end #module GGLib
