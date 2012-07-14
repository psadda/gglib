module GGLib

class LineEdit
  include Widget
  
  attr_reader :selected_text

  def initialize(text = '')
    super(:text_box)
    @text = text
    @text_input = self.window.backend.new_text_input
    @cursor_pos = nil
    @selection_pos = nil
    
    self.on :focus do |this|
      self.window.backend.set_current_text_input(@text_input)
    end

    self.on :update do |this|
      set_text self.window.backend.get_text(@text_input)
      set_caret_pos self.window.backend.get_cursor_position(@text_input)
      set_selection_start self.window.backend.get_selection_position(@text_input)
    end

    self.on :blur do |this|
      self.window.backend.set_current_text_input(nil)
    end
  end

  def selected_text
  end

  def set_selection(start, length)
  end

  def get_selection
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

end

end #module GGLib
