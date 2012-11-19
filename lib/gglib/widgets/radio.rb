module GGLib

class RadioButton
  include Widget

  attr_accessor :value, :checked
  attr_bool :checked
  attr_volatile :checked

  theme_class :radio_button

  def initialize(text, value=nil)
    super()
    @text = text
    value = @text if value.nil?
    @value = value
    @checked = false
  end

end

class RadioGroup
  include Container

  attr_accessor :value

  theme_class :invisible

  def initialize(options = { })
    options.each do |key, value|
      add_option key, value
    end
    @checked_button = nil
  end

  def add_option(name, value=nil)
    self.add RadioButton.new(label, value)
    return nil
  end

  def remove_option(name)
    @children.each do |child|
      if child.kind_of?(RadioButton) and child.text == key
        self.remove(child)
      end
    end
  end

  def value
    return @checked_button.text unless @checked_button.nil?
    return nil
  end

  def value=(val)
    @children.each do |child|
      if child.kind_of?(RadioButton) and child.text == val
        @checked_button.checked = false unless @checked_button.nil?
        child.checked = true
        @checked_button = child
        return @checked_button.text
      end
    end
    return nil
  end
end

end #module
