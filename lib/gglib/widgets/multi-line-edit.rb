module GGLib

class MultiLineEdit < LineEdit

  def initialize
    super
    self.style.horizontal_overflow = Overflow::AUTO
  end

  def draw
    if @visible

    end
    return super
  end

end

end #module GGLib
