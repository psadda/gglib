module GGLib

module Backend

  #
  # Create a new OS window. An application can only have one OS window.
  #
  def create_window
  end
  #
  # Show the OS window.
  #
  def show_window
  end
  #
  # Hide the OS window.
  #
  def hide_window
  end
  #
  # Close the OS window. The window can't be reopened after it is closed.
  #
  def close_window
  end
  #
  # Get the height of the OS window in pixels.
  #
  def window_height
  end
  #
  # Get the width of the OS window in pixels.
  #
  def window_width
  end

  #
  # Get the x-coordinate of the cursor.
  #
  def mouse_x
  end
  #
  # Get the y-coordinate of the cursor.
  #
  def mouse_y
  end
  def is_button_down?(button)
  end

  #
  # Create a handle for a font of the given family and height. Height is specified in pixels.
  # The new handle (usually an integer) is returned.
  #
  def load_font(family, height)
  end
  #
  # Release the internal object associated with the given font handle.
  #
  def unload_font(font_handle)
  end
  #
  # Get the width of text when rendered with the font handle.
  #
  def text_width(font_handle, text)
  end

  #
  # Load the image file at the given path. A handle to the image (usually an integer) is returned.
  #
  def load_image(path)
  end
  #
  # Release the internal object associated with the given image handle.
  #
  def unload_image(image_handle)
  end
  #
  # Get the height of the given image.
  #
  def image_height(image_handle)
  end
  #
  # Get the width of the given image.
  #
  def image_width(image_width)
  end
  #
  # Get the handle for the default image. The default image is small (usually 1 x 1) and completely transparent.
  #
  def default_image
  end

  #
  # Create a new text input object and return a handle to the object. (The handle is usually an integer.)
  #
  # Text input objects are used by the backend to aggregate input from the user into a string.
  #
  def new_text_input
  end
  #
  # Set the text input object that is currently receiving new input.  To ignore new input, pass nil.
  #
  def set_current_text_input(text_input_handle)
  end
  #
  # Get the cursor position of the given text input.
  #  
  def get_text_cursor_position(text_input_handle)
  end
  #
  # Get the selection start position of the given text input.
  #  
  def get_text_selection_position(text_input_handle)
  end
  #
  # Get the text of the given text input.
  #  
  def get_text(text_input_handle)
  end

  #
  # Draw inside the given clipping box.
  #  
  def draw_clipped(x1, y1, x2, y2, &block)
  end
  #
  # Draw an image with its original height and width.
  #  
  def draw_image(image, x1, y1, c)
  end
  #
  # Draw an image by specifying its four corners.
  #  
  def draw_image_stretch(image, x1, y1, x2, y2, x3, y3, x4, y4, color)
  end
  #
  # Draw a rectangle.
  #  
  def draw_rect(x1, y1, x2, y2, color)
  end
  #
  # Draw text.
  #  
  def draw_text(font_handle, x, y, text, color)
  end
  #
  # Update the backend.
  #  
  def flush
  end

end

end #module GGLib
