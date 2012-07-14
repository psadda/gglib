module GGLib

# TODO: Get rid of all of the duck-typing artifacts in this class.

#
# The Cursor is owned by the MainWindow and represents the system cursor within the window.
#
class Cursor
  attr_reader :window
  attr_accessor :x, :y

  attr_accessor :enabled, :disabled
  attr_bool :enabled, :disabled

  attr_accessor :visible, :hidden
  attr_bool :visible, :hidden

  attr_accessor :use_system_cursor
  attr_bool :use_system_cursor

  alias :x1 :x #:nodoc:
  alias :x2 :x #:nodoc:
  alias :y1 :y #:nodoc:
  alias :y2 :y

  #TODO: create a real default renderer
  DEFAULT_RENDERER = CursorImageRenderer.new('../media/themes/obsidian/cursor/normal.png', 5, 2)

  def initialize(window)
    @visible = @enabled = true
    @x = @y = 0
    @renderer = DEFAULT_RENDERER.dup
    @window = window
    @renderer.backend = @window.backend
    @use_system_cursor = false
  end

  def width #:nodoc: (This is provided only for compatibility with the render engine)
    return 0
  end

  def height #:nodoc: (This is provided only for compatibility with the render engine)
    return 0
  end

  def move(x, y)
    @x = value
    @y = value
    return nil
  end

  def resize(w, h) #:nodoc: (This is provided only for compatibility with the render engine)
    return nil
  end

  def disabled?
    return (not @enabled)
  end

  def disabled=(value)
    return (@enabled = (not value))
  end

  def enable
    return (@enabled = true)
  end

  def disable
    return (@enabled = false)
  end

  def hidden?
    return (not @visible)
  end

  def hidden=(value)
    return (@visible = (not @value))
  end

  def hide
    return (@visible = false)
  end

  def show
    return (@visible = true)
  end

  def over?(widget)
    return (not (@x < widget.x1 or @x >= widget.x2 or @y < widget.y1 or @y >= widget.y2))
  end

  def draw
    @renderer.draw(self) if @visible
  end
end

end #module GGLib
