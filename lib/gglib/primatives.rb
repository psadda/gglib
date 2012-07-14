module GGLib

module Primatives

#
# A Renderable is an object that can be rendered. It is a rectangular region of the screen that has a Color and a Renderer.
# (The Renderer is used to draw the Renderable object to the screen.)
#
class Renderable
  attr_accessor :x1, :y1, :x2, :y2, :color
  attr_accessor :x, :y
  attr_accessor :backend

  def initialize(backend)
    @x1 = @y1 = @x2 = @y2 = 0
    @backend = backend
    @color = Color.new
  end

  def initialize_copy(other)
    super
    @x1 = @y1 = @x2 = @y2 = other.x1, other.y1, other.x2, other.y2
    @backend = other.backend
    @color = other.color
  end

  def x
    return @x1
  end

  def y
    return @y1
  end

  def x=(value)
    w = @x2 - @x1
    self.x2 = value + w
    return (self.x1 = value)
  end

  def y=(value)
    h = @y2 - @y1
    self.y2 = value + h
    return (self.y1 = value)
  end

  def redraw(data)
  end

  def draw(data)
  end
end

class SimpleText < Renderable
  attr_accessor :text, :font

  def initialize(backend)
    super
    @text = ''
    @font = @backend.default_font.dup
  end

  def width
    @backend.text_width(@font, @text)
  end

  def draw
    @x2 = @x1 + width
    #TODO: set y2
    @backend.draw_text(@font, @x1, @y1, @text, @color)
  end
end

class Text < Renderable
  include Volatile

  attr_accessor :text, :style

  attr_volatile :x1, :y1, :x2, :y2
  attr_volatile :text, :style

  def initialize(backend)
    super
    @text = ''
    @events = {}
    @cached_lines = []
    @style = Widget::DEFAULT_STYLE
    @dirty = false
    self.subscribe(:modified, self.object_id) do
      @dirty = true
    end
  end

  @@fonts = {}

  private
  class CachedLine
    attr_accessor :text, :x, :y
    def initialize(x, y, text)
      @text = text
      @x = x
      @y = y
    end
  end

  #
  # Break text into lines.
  #
  def pass1(text, style, x1, y1, x2, y2, tabsize=4)
    output = []

    return output if text.empty? or text.strip.empty?

    ws = text.gsub("\t", ' '*tabsize).split(/\S+/).reverse
    text = text.split.reverse
    #ws.push('') if ws.size == text.size

    y1 += style.padding.top
    x1 += style.padding.left
    y2 -= style.padding.bottom
    x2 -= style.padding.right

    width = x2 - x1

    font_handle = get_font_handle(style.font.family, style.font.height)

    line = nil
    newword = nil
    lines = 0
    newline = ''

    while text.size > 0

      line = newline
      newword = text.pop
      lines = ws.last.count("\n")
      if lines == 0
        newline += ws.pop
        temp_ws = ''
      else
        temp_ws = ws.pop.gsub(/\A.*\n/, '')
      end

      newline += newword

      if @backend.text_width(font_handle, newline) > width or lines > 0
        output.push(line.rstrip)
        newline = temp_ws + newword
      end

    end

    output.push(newline.rstrip)
  end

  #
  # Vertically and horizontally align the output of pass1.
  #
  def pass2(lines, style, x1, y1, x2, y2)
    return lines if lines.empty?

    output = []

    y1 += style.padding.top
    x1 += style.padding.left
    y2 -= style.padding.bottom
    x2 -= style.padding.right

    output_height = lines.size * style.font.height + (lines.size - 1) * style.line_spacing

    width = x2 - x1
    height = y2 - y1
    y_position = case style.vertical_align
      when VerticalAlign::TOP then y1
      when VerticalAlign::MIDDLE then y1+ ((height - output_height)/2).floor
      when VerticalAlign::BOTTOM then y2 - output_height
    end

    x_position = nil

    font_handle = get_font_handle(style.font.family, style.font.height)

    lines.each do |line|

      x_position = case style.align
        when Align::LEFT then x1
        when Align::RIGHT then x2 - @backend.text_width(font_handle, line)
        when Align::CENTER then x1 + ( (width - @backend.text_width(font_handle, line)) / 2).floor
      end

      if x_position + @backend.text_width(font_handle, line) > x2
        #x overflow
      end

      output.push(CachedLine.new(x_position, y_position, line))

      y_position += style.font.height
      y_position += style.line_spacing

      if y_position > y2
        #y overflow
      end

    end

    return output
  end

  def process_text(text, style, x1, y1, x2, y2, tabsize=4)
    @cached_lines = pass2(pass1(text, style, x1, y1, x2, y2, tabsize), style, x1, y1, x2, y2)
  end

  #
  # get_font_handle returns a font handle of the type used by the renderer
  # for the specified font family and font height. If a font handle already
  # exists for the given parameters, get_font_handle will return a reference
  # to that handle instead of creating a new copy of the handle.
  #
  def get_font_handle(family, height)
    key = "#{family}#{height}"
    if @@fonts.has_key?(key)
      return @@fonts[key]
    else
      ret = @backend.load_font(family, height)
      @@fonts[key] = ret
      return ret
    end
  end
  
  public
  def draw
    process_text(@text, @style, @x1, @y1, @x2, @y2) if @dirty
    @dirty = false
    @cached_lines.each do |line|
      @backend.draw_text(get_font_handle(@style.font.family, @style.font.height), line.x, line.y, line.text, @style.font.color)
    end
  end

end

class FlexibleGrid < Renderable
  include Volatile

  attr_accessor :top_left, :top_right, :bottom_left, :bottom_right, :center, :top, :bottom, :left, :right
  attr_accessor :top_min, :right_min, :bottom_min, :left_min, :horizontal_min, :vertical_min
  attr_accessor :margin_left, :margin_right, :margin_top, :margin_bottom

  attr_volatile :x1, :y1, :x2, :y2
  attr_volatile :top_left, :top_right, :bottom_left, :bottom_right, :center, :top, :bottom, :left, :right
  attr_volatile :top_min, :right_min, :bottom_min, :left_min, :horizontal_min, :vertical_min
  attr_volatile :margin_left, :margin_right, :margin_top, :margin_bottom

  def initialize(renderer)
    super
    image = Image.new(@backend)
    @top_left = image
    @top_right = image
    @bottom_left = image
    @bottom_right = image
    @top = image
    @right = image
    @bottom = image
    @left = image
    @center = image
    @margin_top = 0
    @margin_right = 0
    @margin_bottom = 0
    @margin_left = 0
    @events = { }
    self.subscribe(:modified, self.object_id) do
      @dirty = true
    end
    @dirty = true
  end

  public
  def initialize_copy(other)
    super
    @top_left = other.top_left
    @top_right = other.top_right
    @bottom_left = other.bottom_left
    @bottom_right = other.bottom_right
    @top = other.top
    @right = other.right
    @bottom = other.bottom
    @left = other.left
    @center = other.center
    @margin_top = other.margin_top
    @margin_right = other.margin_right
    @margin_bottom = other.margin_bottom
    @margin_left = other.margin_left
    @events = { }
    self.subscribe(:modified, self.object_id) do
      @dirty = true
    end
    @dirty = true    
  end

  def natural_width
    return @margin_left + @left.natural_width + @center.natural_width + @right.natural_width + @margin_right
  end

  def natural_height
    return @margin_top + @top.natural_height + @center.natural_height + @bottom.natural_height + @margin_bottom
  end

  def draw
    calculate_dimensions if @dirty
    @dirty = false

    @top_left.draw
    @top.draw
    @top_right.draw
    @right.draw
    @bottom_right.draw
    @bottom.draw
    @bottom_left.draw
    @left.draw
    @center.draw

    return nil
  end

  private
  def resize_cell(cell, x1, y1, width, height)
    cell.x1 = x1
    cell.x2 = x1 + width
    cell.y1 = y1
    cell.y2 = y1 + height
  end

  def calculate_dimensions
    top_height = @top.natural_height
    right_width = @right.natural_width
    bottom_height = @bottom.natural_height
    left_width = @left.natural_width

    mmargin_left = @margin_left
    mmargin_right = @margin_right
    mmargin_top = @margin_top
    mmargin_bottom = @margin_bottom

    mx1 = @x1 + mmargin_left
    my1 = @y1 + mmargin_top
    mx2 = @x2 - mmargin_right
    my2 = @y2 - mmargin_bottom

    w = mx2 - mx1
    h = my2 - my1

    if w < left_width + 1 + right_width
      # Scale down vertically
      # Algorithm:
      # w = margin_left * scale_factor + x2 - x1 + margin_right * scale_factor
      # scale_factor * left_width + 1 + scale_factor * right_width = w
      # scale_factor = (x2 - x1 - 1) / (left_width + right_width - margin_left - margin_right)
      scale_factor = (@x2 - @x1).to_f / (left_width + right_width - @margin_left - @margin_right).to_f
      left_width *= scale_factor
      right_width *= scale_factor
      left_width = left_width.round.to_i
      right_width = right_width.round.to_i
      mmargin_left = (@margin_left * scale_factor).round.to_i
      mmargin_right = (@margin_right * scale_factor).round.to_i
    end

    if h < top_height + 1 + bottom_height
      # Scale down horizontally
      # Algorithm:
      # h = margin_top * scale_factor + y2 - y1 + margin_bottom * scale_factor
      # scale_factor * top_height + 1 + scale_factor * bottom_height = h
      # scale_factor = (y2 - y1 -1) / (top_height + bottom_height - margin_top - margin_bottom)
      scale_factor = (@y2 - @y1 - 1).to_f / (top_height + bottom_height - @margin_top - @margin_bottom).to_f
      top_height *= scale_factor
      bottom_height *= scale_factor
      top_height = top_height.round.to_i
      bottom_height = bottom_height.round.to_i
      mmargin_top = (@margin_top * scale_factor).round.to_i
      mmargin_bottom = (@margin_bottom * scale_factor).round.to_i
    end

    mx1 = @x1 + mmargin_left
    my1 = @y1 + mmargin_top
    mx2 = @x2 - mmargin_right
    my2 = @y2 - mmargin_bottom

    w = mx2 - mx1
    h = my2 - my1

    center_width = w - (left_width + right_width)
    center_height = h - (top_height + bottom_height)

    resize_cell(
      @top_left,
      mx1,
      my1,
      left_width,
      top_height
    )

    resize_cell(
      @top,
      @top_left.x2,
      my1,
      center_width,
      top_height
    )

    resize_cell(
      @top_right,
      @top.x2,
      my1,
      right_width,
      top_height
    )

    resize_cell(
      @left,
      mx1,
      @top_left.y2,
      left_width,
      center_height
    )

    resize_cell(
      @center,
      @left.x2,
      @top.y2,
      center_width,
      center_height
    )

    resize_cell(
      @right,
      @center.x2,
      @top_right.y2,
      right_width,
      center_height
    )

    resize_cell(
      @bottom_left,
      mx1,
      @left.y2,
      left_width,
      bottom_height
    )

    resize_cell(
      @bottom,
      @top_left.x2,
      @center.y2,
      center_width,
      bottom_height
    )

    resize_cell(
      @bottom_right,
      @bottom.x2,
      @right.y2,
      right_width,
      bottom_height
    )
  end

end

class Image < Renderable
  attr_accessor :image
  attr_accessor :auto_size
  attr_bool :auto_size

  def initialize(renderer)
    super
    @image = @backend.default_image
    @auto_size = false
  end

  def auto_size=(value)
    return (@auto_size = value)
  end

  def image=(value)
    @image = value
    return value
  end

  def natural_height
    return @backend.image_height(@image)
  end

  def natural_width
    return @backend.image_width(@image)
  end

  def draw
    if @auto_size
      @x2 = @x1 + natural_width
      @y2 = @y1 + natural_height
    end
    @backend.draw_image_stretch(@image, @x1, @y1, @x2, @y2, @color)
  end
end

class Rectangle < Renderable
  def draw
    @backend.draw_rect(@x1, @y1, @x2, @y2, @color)
  end
end

end #module Primatives

end #module GGLib
