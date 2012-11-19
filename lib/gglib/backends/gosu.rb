require 'gosu'

require $gglroot + '/gglib/backends/gosu/buttons'

module GGLib

class GosuWindowWrapper < Gosu::Window #:nodoc: (This is an implementation detail)

  def initialize(main_window_widget, width, height, fullscreen, update_interval)
    @main_window_widget = main_window_widget
    super(width, height, fullscreen, update_interval)
  end

  def button_down(id)
    @main_window_widget.button_down(Buttons::Gosu2GGLib[id])
  end

  def button_up(id)
    @main_window_widget.button_up(Buttons::Gosu2GGLib[id])
  end

  def update
    @main_window_widget.update
  end

  #TODO: fix this method
  #def needs_cursor?
  #  return @main_window_widget.cursor.use_system_cursor?
  #end

  def needs_redraw?
    return (@main_window_widget.needs_redraw? or not @main_window_widget.throttle_render?)
  end

  def draw
    @main_window_widget.draw
  end

end

class GosuBackend

  include Backend

  def initialize(main_window_widget, z = 0, width_or_window = nil, height = nil, fullscreen = nil, update_interval = nil)
    GGLib::backend = self
    @images = { }
    @image_lookup = { }
    @fonts = { }
    @text_inputs = { }
    @main_window_widget = main_window_widget
    if width_or_window.kind_of?(Fixnum)
      # The caller has supplied parameters to create a window
      @window = nil
      create_window
    elsif width_or_window.kind_of?(Gosu::Window)
      # The caller has supplied a Gosu::Window
      @window = width_or_window
    else
      raise ArgumentError.new 'Expected a Gosu::Window or parameters for Gosu::Window#initialize'
    end
    @images[0] = Gosu::Image.new(@window, $gglroot+'/../media/null.png', false)
    @image_lookup[File.expand_path($gglroot+'/../media/null.png')] = 0
    @image_count = 1
    @font_count = 0
    @text_input_count = 0
    @z = z
  end

  def create_window(width = 640, height = 480, fullscreen = false, update_interval = 16.666666)
    if @window.nil?
      @window = GosuWindowWrapper.new(@main_window_widget, width, height, fullscreen, update_interval)
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

  def button_down?(button)
    return @window.button_down?(Buttons::GGLib2Gosu[button])
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

# TODO: be more specific in the below documentation about how an internal window is created
#
# GosuWindow is a MainWindow implementation for applications using the Gosu library.
# It is not necessary to use GosuWindow; it is also possible to create and manage a MainWindow
# directly. GosuWindow is simply a convenience class for developing Gosu applications.
#
class GosuWindow

  include MainWindow

  def initialize(width = 640, height = 480, fullscreen = false, update_interval = 16.666666)
    GGLib::default_window = self
    super(GosuBackend.new(self, 0, width, height, fullscreen, update_interval))
  end

end

GGLib::default_window = GosuWindow.new

#
# There are two ways to use The Gosu backend for GGLib:
#
# Let GGLib manage the window:
#
# GGLib::GosuWindow.new(640, 480, false, 20)
#
# Manage the window yourself:
#
# class MyCustomGosuWindow < Gosu::Window
#
#   attr_reader :main_window_widget
#
#   def initialize
#     super(640, 480, false, 20)
#     @main_window_widget = GGLib::MainWindow.new
#   end
#
#   def update
#     @main_window_widget.update
#   end
#
#   def draw
#     @main_window_widget.draw
#   end
#
#   def button_down(id)
#     @main_window_widget.button_down(id)
#   end
#
#   def button_up(id)
#     @main_window_widget.button_up(id)
#   end
#
# end
#
# my_window = MyCustomGosuWindow.new(640, 480, false, 20)
# z_order = 0 # All Gosu objects will be rendered with this z order
# GGLib::GosuBackend.new(my_window.main_window_widget, z_order, my_window)
#

end
