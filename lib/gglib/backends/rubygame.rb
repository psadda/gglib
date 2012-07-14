require 'rubygame'

module GGLib

class RubygameWindow
  include MainWindow

  def initialize
    @opened = false
    super(RubygameBackend.new(self), nil)
  end

  def show
    if @opened
      return @backend.show_window
    else
      return @backend.open_window
    end
  end
end

class RubygameBackend
  include Backend

  def initialize(main_window_widget, screen = nil)
    @images = { }
    @fonts = { }
    @image_count = 0
    @font_count = 0
    @main_window_widget = main_window_widget
    @mouse_pos = [0, 0]
    Rubygame::TTF.setup
    create_window if screen.nil?
  end

  def window_width
    @screen.size[0]
  end
  def window_height
    @screen.size[1]
  end
  def mouse_x
    return @mouse_pos[0]
  end
  def mouse_y
    return @mouse_pos[1]
  end

  def create_window
    if @screen.nil?
      width = Rubygame::Screen.get_resolution[0]
      height = Rubygame::Screen.get_resolution[1]
      @screen = Rubygame::Screen.new([width, height], 0, [Rubygame::SWSURFACE, Rubygame::FULLSCREEN])
      @event_queue = Rubygame::EventQueue.new
      @event_queue.enable_new_style_events
    end
    return true
  end
  def window_is_open
    return Rubygame::Screen::open?
  end
  def open_window
    while event = @event_queue.wait
      @main_window_widget.draw
      @screen.flip
      if event.kind_of?(Rubygame::Events::MouseMoved)
        @mouse_pos = event.pos
      end
      #@main_window_widget.inject_event(event)
      @main_window_widget.update
      break if event.is_a? Rubygame::Events::QuitRequested
    end
    return true
  end
  def show_window
    return false
  end
  def hide_window
    return false
  end
  def close_window
    @screen.close
    return true
  end

  def load_font(family, height)
    family = "C:/Windows/Fonts/#{family}.ttf"
    @font_count+=1
    @fonts[@font_count] = Rubygame::TTF.new(family, height)
    return @font_count
  end
  def unload_font(font)
    @fonts.delete(font)
    return font
  end
  def text_width(font, text)
    return @fonts[font].size_unicode(text)[0]
  end

  def load_image(path)
    @image_count+=1
    @images[@image_count] = Rubygame::Surface.load(path).to_display_alpha
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

  def draw_image(image, x1, y1, c)
    @images[image].set_alpha(make_alpha(c)).blit(@screen, [x1, y1])
    return true
  end
  def draw_image_stretch(image, x1, y1, x2, y2, c)
    @images[image].zoom_to(x2 - x1, y2 - y1, true).set_alpha(make_alpha(c)).blit(@screen, [x1, y1])
    return true
  end
  def draw_rect(x1, y1, x2, y2, c)
    @screen.draw_box_s([x1, y1], [x2, y2], make_color(c))
    return true
  end
  def draw_quad(x1, y1, x2, y2, x3, y3, x4, y4, c)
    @screen.draw_polygon_s([ [x1, y1], [x2, y2], [x3, y3], [x4, y4] ], make_color(c)) 
    return true
  end
  def draw_triangle(x1, y1, x2, y2, x3, y3, c) 
    @screen.draw_polygon_s([ [x1, y1], [x2, y2], [x3, y3] ], make_color(c)) 
    return true
  end
  def draw_line(x1, y1, x2, y2, c)
    @screen.draw_line([x1, y1], [x2, y2], make_color(c))
    return true
  end
  def draw_text(font, x, y, text, color)
    @fonts[font].render_unicode(text, true, make_color(color))
    return true
  end
  def flush
    return true
  end

  private
  def make_color(color)
    return GGLib::Color.new(color).to_rubygame
  end
  def make_alpha(color)
    return GGLib::Color.new(color).alpha
  end
end

end
