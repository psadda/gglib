module GGLib

#
# A LineEdit is a text box that can be used to edit a single line of text. Use a MultiLineEdit to
# edit more than one line of text.
#
class LineEdit
  include Widget

  attr_reader :selected_text, :selection
  attr_accessor :cursor_blink_rate

  DefaultCursorBlinkRate = 70

  def initialize(maximum_length = nil)
    super()
    @text_input = self.window.backend.new_text_input
    @cursor_pos = @x1
    @selection_pos = @x1
    @cursor_blink_rate = DefaultCursorBlinkRate
    @cycles_until_next_cursor_draw = @cursor_blink_rate

    self.style.align = Align::Left
    self.style.vertical_align = VerticalAlign::Top
    self.style.horizontal_overflow = Overflow::Hide

    self.activatable = true

    self.on :activate do |this|
      self.window.backend.set_current_text_input(@text_input)
    end

    self.on :deactivate do |this|
      self.window.backend.set_current_text_input(nil)
    end

    self.on :update do |this|
      set_text self.window.backend.text(@text_input)
      @cursor_pos = self.window.backend.text_cursor_position(@text_input)
      @selection_pos = self.window.backend.text_selection_start_position(@text_input)

      @cycles_until_next_cursor_draw -= 1
      if @cycles_until_next_cursor_draw < 0
        @cycles_until_next_cursor_draw = @cursor_blink_rate
      elsif should_draw_cursor
        damage(:ibeam)
      end
    end

    self.on :button_down, :key_c do |this|
      if self.window.button_down?(:key_left_control) or self.window.button_down?(:key_right_control)
        self.window.clipboard_text = self.selected_text
      end
    end

    self.on :button_down, :key_v do |this|
      if self.window.button_down?(:key_left_control) or self.window.button_down?(:key_right_control)
        self.text += self.window.clipboard_text
      end
    end
  end

  def theme_class
    :line_edit
  end

  def set_container(object) #:nodoc: (This is an implementation detail)
    @cursor = Primatives::Rectangle.new(object.window.backend)
    @selection = Primatives::Rectangle.new(object.window.backend)
    @cursor.color = GGLib::Color.new(0, 0, 0)
    @selection.color = GGLib::Color.new(255, 255, 0, 75)
    return super
  end

  def selected_text
    return @text.slice(@selection_pos, @cursor_pos - @selection_pos)
  end

  #def selection=(selection)
  #end

  def selection
    return [@selection_pos, @cursor_pos - @selection_pos]
  end

  private
  def set_text(text)
    self.text = text unless self.text == text
  end

  def set_cursor_position(pos)
    @cursor_pos = pos
  end

  def set_selection_position(pos)
    @selection_pos = pos
  end

  def should_draw_cursor
    return (@cycles_until_next_cursor_draw > (@cursor_blink_rate / 2).floor and self.active?)
  end

  public
  def draw
    super
    if @visible
      cb = @style.renderer.content_bounds(self)
      x_offset = cb[0][0]
      y_offset = cb[0][1]

      top = y_offset - 1
      bottom = top + @style.font.height + 1
      cursor_x = @style.renderer.text_width(self, @text.slice(0, @cursor_pos)) + x_offset
      selection_x = @style.renderer.text_width(self, @text.slice(0, @selection_pos)) + x_offset

      if should_draw_cursor and cursor_x < cb[1][0]
        @cursor.x1 = cursor_x
        @cursor.y1 = top
        @cursor.x2 = cursor_x + 1
        @cursor.y2 = bottom
        @cursor.draw
      end

      right_bound = cb[1][0]
      selection_x = (selection_x < right_bound)? selection_x : right_bound
      selection_end_x = (cursor_x < right_bound)? cursor_x : right_bound

      @selection.x1 = selection_x
      @selection.y1 = top
      @selection.x2 = selection_end_x
      @selection.y2 = bottom
      @selection.draw
    end
    return @visible
  end

end

end
