begin
require 'gosu'
rescue LoadError
end

module GGLib

class GosuWindowWrapper < Gosu::Window #:nodoc:
  def initialize(main_window_widget)
    @main_window_widget = main_window_widget
    super(640, 480, false)
  end

  def button_down(id)
    focused_widget = @main_window_widget.focused_widget
    active_widget = @main_window_widget.active_widget
    case id
      when Gosu::MsLeft
      @main_window_widget.set_active_widget(focused_widget)
        focused_widget.signal :mouse_down, :left, mouse_x, mouse_y
        active_widget.signal :mouse_drag, :start, mouse_x, mouse_y
        @in_drag = true
        @drag_x = mouse_x
        @drag_y = mouse_y
      when Gosu::MsMiddle
        focused_widget.signal :mouse_down, :middle
      when Gosu::MsRight
        focused_widget.signal :mouse_down, :right
      else
        focused_widget.signal :key_down
    end
  end

  def button_up(id)
    focused_widget = @main_window_widget.focused_widget
    case id
      when Gosu::MsLeft
        focused_widget.signal :mouse_up, :left, mouse_x, mouse_y
        focused_widget.signal :click, mouse_x, mouse_y
        @in_drag = false
      when Gosu::MsMiddle
        focused_widget.signal :mouse_up, :middle, mouse_x, mouse_y
      when Gosu::MsRight
        focused_widget.signal :mouse_up, :right, mouse_x, mouse_y
        active_widget.signal :mouse_drag, :end, mouse_x, mouse_y
      else
        focused_widget.signal :key_up
        focused_widget.signal :key_press
    end
  end

  def update
    begin
      @main_window_widget.update
      focused_widget = @main_window_widget.focused_widget
      if @in_drag
        @main_window_widget.active_widget.signal(:mouse_drag, :continue, mouse_x - @drag_x, mouse_y - @drag_y)
        @main_window_widget.active_widget.signal(:drag, mouse_x - @drag_x, mouse_y - @drag_y)
        @drag_x = mouse_x
        @drag_y = mouse_y
      end
      if button_down?(Gosu::MsLeft)
        focused_widget.signal :unbuffered_mouse_down, :left, mouse_x, mouse_y
      end
      if button_down?(Gosu::MsMiddle)
        focused_widget.signal :unbuffered_mouse_up, :middle, mouse_x, mouse_y
      end
      if button_down?(Gosu::MsRight)
        focused_widget.signal :unbuffered_mouse_up, :right, mouse_x, mouse_y
      end
    rescue SystemExit
      close
    rescue Exception => e
      puts e.message
      puts e.backtrace
      close
    end
    return nil
  end

  #TODO:fix this method
  #def needs_cursor?
  #  return @main_window_widget.cursor.use_system_cursor?
  #end
  def needs_redraw?
    return (@main_window_widget.needs_redraw? or not @main_window_widget.throttle_render?)
  end

  def draw
    begin
      @main_window_widget.draw
    rescue SystemExit
      close
    rescue Exception => e
      puts e.message
      puts e.backtrace
      close
    end
    return nil
  end
end

class GosuBackend
  include Backend

  def initialize(main_window_widget, z = 0)
    @images = { }
    @image_lookup = { }
    @fonts = { }
    @text_inputs = { }
    @window = nil
    @main_window_widget = main_window_widget
    create_window
    @images[0] = Gosu::Image.new(@window, '../media/null.png', false)
    @image_lookup[File.expand_path('../media/null.png')] = 0
    @image_count = 1
    @font_count = 0
    @text_input_count = 0
    @z = z
  end

  def create_window
    if @window.nil?
      @window = GosuWindowWrapper.new(@main_window_widget)
    end
    return true
  end

  def show_window
    @window.show
    return true
  end

  def hide_window
    return false
  end

  def close_window
    @window.close
    return true
  end

  def window_height
    return @window.height
  end

  def window_width
    return @window.width
  end

  def mouse_x
    return @window.mouse_x
  end

  def mouse_y
    return @window.mouse_y
  end

  def is_button_down?(button)
  end

  def load_font(family, height)
    @font_count+=1
    @fonts[@font_count] = Gosu::Font.new(@window, family, height)
    return @font_count
  end

  def unload_font(font)
    @fonts.delete(font)
    return font
  end

  def text_width(font, text)
    return @fonts[font].text_width(text)
  end

  def load_image(path)
    path = File.expand_path(path)

    # Search for cached image
    if @image_lookup.has_key?(path)
      index = @image_lookup[path]
      if @images.has_key?(index)
        # Cache hit
        return index
      else
        # Dangling reference: remove the reference and continue loading the image
        @image_lookup.delete(index)
      end
    end

    # Cached image was not found. Load image.
    @image_count += 1
    begin
      @images[@image_count] = Gosu::Image.new(@window, path, true)
    rescue
      raise "Could not find #{path}"
    end
    return @image_count
  end

  def unload_image(image)
    @images.delete(image)
    return image
  end

  def image_height(image)
    return @images[image].height
  end

  def image_width(image)
    return @images[image].width
  end

  def new_text_input
    @text_inputs[@text_input_count] = Gosu::TextInput.new
    ret = @text_input_count
    @text_input_count += 1
    return ret
  end

  def  set_current_text_input(id)
    unless id.nil?
      @window.text_input = @text_inputs[id]
    else
      @window.text_input = nil
    end
  end

  def text_cursor_position(id)
    return @text_inputs[id].caret_pos
  end

  def text_selection_start_position(id)
    return @text_inputs[id].selection_start
  end

  def text(id)
    return @text_inputs[id].text
  end

  def default_image
    return 0
  end

  def draw_clipped(x1, y1, x2, y2, &block)
    @window.clip_to(x1, y1, x2 - x1, y2 - y1, &block)
    return true
  end

  def draw_image(image, x1, y1, a)
    a = a.to_gosu
    @images[image].draw(x1, y1, @z, 1.0, 1.0, a)
    return true
  end

  def draw_image_stretch(image, x1, y1, x2, y2, a)
    a = a.to_gosu
    @images[image].draw_as_quad(x1, y1, a, x2, y1, a, x1, y2, a, x2, y2, a, @z)
    return true
  end

  def draw_rect(x1, y1, x2, y2, c)
    c = c.to_gosu
    @window.draw_quad(x1, y1, c, x2, y1, c, x1, y2, c, x2, y2, c, @z)
    return true
  end

  def draw_text(font, x, y, text, c)
    c = c.to_gosu
    @fonts[font].draw(text, x, y, @z, 1.0, 1.0, c)
    return true
  end

  def flush
    return true
  end

end

#
# GosuWindow is a MainWindow implementation for applications using the Gosu library.
# It is not necessary to use GosuWindow; it is also possible to create and manage a MainWindow
# directly. GosuWindow is simply a convenience class for developing Gosu applications.
#
class GosuWindow
  include MainWindow
  def initialize
    GGLib::default_window = self
    super(GosuBackend.new(self), nil)
  end
end

GGLib::default_window = GosuWindow.new

end #module GGLib
