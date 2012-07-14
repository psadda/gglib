module GGLib

#
# A Theme selects the Renderer that should be used to draw a Widget.
#
class Theme
  #
  # Get the Renderer that should be used to draw the given Widget.
  #
  def renderer_for(widget)
  end
end

#
# A convenience class for creating new Theme classes. CustomTheme keeps a hash called
# @renderers that maps symbols (those returned by Widget#theme_class) to renderers.
#
class CustomTheme
  #
  # Get the Renderer that should be used to draw the given Widget.
  #
  # Do not override this function when inheriting from CustomTheme. Build the @renderers
  # hash in the initialize method instead.
  #
  def renderer_for(widget)
    return nil if widget.theme_class == :invisible
    ret = @renderers[widget.theme_class]
    return ret unless ret.nil?
    return @renderers[:default]
  end
end

#
# A Renderer draws a Widget to the screen using Primatives.
#
class Renderer
  include Volatile

  def initialize
    super()
    unless GGLib::default_window.nil?
      self.backend = GGLib::default_window.backend
    else
      self.backend = nil
    end
  end

  def backend=(val)
    unless val.nil? or @backend == val
      set_backend(val)
    end
    return (@backend = val)
  end

  private
  #
  # Used in subclasses to set the backend for all of the Primatives that are used in drawing.
  #
  def set_backend(val)
  end

  public
  def suggested_width(widget)
    return widget.width
  end

  def suggested_height(widget)
    return widget.height
  end

  def suggested_style(widget)
    return widget.style
  end

  #
  # Attempt to draw the given Widget. Return true if the given Widget was drawn and
  # false if it was not drawn. The Widget will not be drawn if it is not inside a MainWindow
  # or if no Backend has been set for the Renderer.
  #
  def draw(widget)
    return (not (@backend.nil? or widget.window.nil?))
  end

  protected
  #
  # Convenience function for implementations of ThemeRenderer. draw_text
  # renders text according to the Style information on the widget.
  # Implementations of ThemeRenderer may use this function if they choose
  # to honor Style information. If an implementation chooses not to honor
  # Style information, it may render text directly.
  #
  # draw_text also allows for the caching of Primatives::Text objects: the
  # text justification will be recalculated only when necessary.
  #
  def draw_text(widget, x1, y1, x2, y2)
    textp = widget.get_field(:'GGLib.Renderer/cached-text')
    unless textp.nil?
      textp.text = widget.text unless textp.text == widget.text
      textp.style = widget.style unless textp.style == widget.style
      textp.x1 = x1 unless textp.x1 == x1
      textp.y1 = y1 unless textp.y1 == y1
      textp.x2 = x2 unless textp.x2 == x2
      textp.y2 = y2 unless textp.y2 == y2
    else
      textp = Primatives::Text.new(@backend)
      textp.text = widget.text
      textp.style = widget.style
      textp.x1 = x1
      textp.y1 = y1
      textp.x2 = x2
      textp.y2 = y2
      widget.set_field(:'GGLib.Renderer/cached-text', textp)
    end
    textp.draw
  end
end

class SolidRenderer < Renderer
  def initialize(color)
    @color = color
    super()
  end

  def set_backend(backend)
    @rect = Primatives::Rectangle.new(backend)
  end

  def draw(widget)
    return false unless super
    @rect.color, @rect.x1, @rect.y1, @rect.x2, @rect.y2 = @color, widget.x1, widget.y1, widget.x2, widget.y2
    @rect.draw
  end
end

#
# An ImageRenderer draws an image to the screen. The height and width of the image can be adjusted.
#
class ImageRenderer < Renderer

  #
  # If auto_size is true, the ImageRenderer will use the original dimensions of the image. auto_size is
  # false by default.
  #
  attr_accessor :auto_size
  attr_bool :auto_size

  #
  # Create an ImageRenderer that will draw the image file at the given location.
  #
  def initialize(image)
    @image_location = image
    @auto_size = false
    super()
  end

  def set_backend(backend)
    @img = Primatives::Image.new(backend)
    @img.image = backend.load_image(@image_location)
  end

  def suggested_width(widget)
    return @img.natural_width
  end

  def suggested_height(widget)
    return @img.natural_height
  end

  def draw(widget)
    return false unless super
    @img.auto_size = @auto_size
    @img.x1, @img.y1 = widget.x1, widget.y1
    @img.draw
    draw_text(widget, widget.x1, widget.y1, widget.x2, widget.y2)
  end
end

#
# An CursorImageRenderer draws an image to the screen to represent the cursor. The height and width of the image **cannot** be adjusted.
#
class CursorImageRenderer < Renderer
  attr_accessor :offset_x, :offset_y

  def initialize(image, offset_x = 0, offset_y = 0)
    @image_location = image
    @offset_x = offset_x
    @offset_y = offset_y
    super()
  end

  def set_backend(backend)
    @img = Primatives::Image.new(backend)
    @img.auto_size = true
    @img.image = backend.load_image(@image_location)
  end

  def draw(widget)
    return false unless super
    @img.x, @img.y = widget.x1 - @offset_x, widget.y1 - @offset_y
    @img.draw
  end
end

#
# A WidgetRenderer is a collection of nine ImageRenderer objects arranged in a 3x3 grid. The grid
# can stretch and shrink to accomodate the size of the Widget that is being drawn.
#
class WidgetRenderer < Renderer
  attr_accessor :margin_top, :margin_right, :margin_bottom, :margin_left
  attr_accessor :padding_top, :padding_right, :padding_bottom, :padding_left

  #attr_volatile :margin_top, :margin_right, :margin_bottom, :margin_left
  #attr_volatile :padding_top, :padding_right, :padding_bottom, :padding_left

  def initialize(resource_path, *states)
    @margin_top = 0
    @margin_right = 0
    @margin_bottom = 0
    @margin_left = 0
    @padding_top = 0
    @padding_right = 0
    @padding_bottom = 0
    @padding_left = 0
    @resource_path = resource_path
    @states = states
    super()
  end

  def set_backend(backend)
    @grids = { }
    @states.each do |state|
      fg = Primatives::FlexibleGrid.new(backend)
      %w(top-left top-right bottom-left bottom-right top right bottom left center).each do |cell|
        tx = Primatives::Image.new(backend)
        tx.image = backend.load_image("#{@resource_path}/#{state}-#{cell}.png")
        fg.send(cell.gsub('-','_')+'=', tx)
      end
      @grids[state.to_sym] = fg
    end
  end

  def suggested_width(widget)
    grid = @grids[:enabled]
    grid.margin_left = @margin_left
    grid.margin_top = @margin_top
    grid.margin_right = @margin_right
    grid.margin_bottom = @margin_bottom
    return grid.natural_width
  end

  def suggested_height(widget)
    grid = @grids[:enabled]
    grid.margin_left = @margin_left
    grid.margin_top = @margin_top
    grid.margin_right = @margin_right
    grid.margin_bottom = @margin_bottom
    return  grid.natural_height
  end

  def draw(widget)
    return false unless super
    #unless widget.has_field?(:'GGLib.Grid9Renderer/grid-map')
    #  widget.set_field(:'GGLib.Grid9Renderer/grid-map', dup_grid_map(@grids))
    #  #widget.set_field(:'GGLib.Grid9Renderer/up-to-date', false)
    #end
    #grids = widget.get_field(:'GGLib.Grid9Renderer/grid-map')
    grids = @grids
    grid = case 
      when (grids.has_key?(:disabled) and widget.disabled?)
        grids[:disabled]
      when (grids.has_key?(:down) and widget.down?)
        grids[:down]
      when (grids.has_key?(:focused) and widget.focused?)
        grids[:focused]
      when (grids.has_key?(:active) and widget.active?)
        grids[:active]
      else
        grids.fetch(:enabled)
    end
    grid.x1, grid.y1, grid.x2, grid.y2 = widget.x1, widget.y1, widget.x2, widget.y2
    grid.margin_left = @margin_left unless grid.margin_left == @margin_left
    grid.margin_top = @margin_top unless grid.margin_top == @margin_top
    grid.margin_right = @margin_right unless grid.margin_right == @margin_right
    grid.margin_bottom = @margin_bottom unless grid.margin_bottom == @margin_bottom
    grid.draw
    draw_text(widget,
      grid.center.x1 + @padding_left,
      grid.center.y1 + @padding_top,
      grid.center.x2 - @padding_right,
      grid.center.y2 - @padding_bottom
    )
    return true
  end

  private
  def dup_grid_map(grid_map)
    new_grid_map = Hash.new
    grid_map.each do |key, value|
      new_grid_map[key] = value.dup
    end
    return new_grid_map
  end
end

#
# Helper function for creating instances of WidgetRenderer
#
def GGLib.grid9renderer(path, states, margin, padding)
  r = WidgetRenderer.new(path, *states)
  r.margin_top = margin[0]
  r.margin_right = margin[1]
  r.margin_bottom = margin[2]
  r.margin_left = margin[3]
  r.padding_top = padding[0]
  r.padding_right = padding[1]
  r.padding_bottom = padding[2]
  r.padding_left = padding[3]
  return r
end

#
# Helper function for specifying theme states for grid9renderer.
#
def GGLib.states(*args)
  return args
end

#
# Helper function for specifying margin arguments for grid9renderer in a CSS-like manner.
#
def GGLib.margin(top = nil, right = nil, bottom = nil, left = nil)
  return [0, 0, 0, 0] if top.nil?
  return [top, top, top, top] if right.nil?
  return [top, right, bottom, left]
end

#
# Helper function for specifying padding arguments for grid9renderer in a CSS-like manner.
#
def GGLib.padding(top = nil, right = nil, bottom = nil, left = nil)
  return [0, 0, 0, 0] if top.nil?
  return [top, top, top, top] if right.nil?
  return [top, right, bottom, left]
end

end #module GGLib
