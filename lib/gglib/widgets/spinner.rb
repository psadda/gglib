module GGLib

class Spinner
  include CompoundWidget

  attr_accessor :type

  def initialize(type = :horizontal)
    super(:invisible)
    @container.style.renderer = nil
    @type = type
  end

  private
  def repair
    if @type == :horizontal
      @increase = SpinnerRight.new
      @decrease = SpinnerLeft.new
    else
      @increase = SpinnerDown.new
      @decrease = SpinnerUp.new
    end
  end

  public
  def draw
    visible = super

    if damaged?
      repair
    end

    return visible
  end

  attr_volatile :type
end

class SpinnerUp
end

class SpinnerDown
end

class SpinnerLeft
end

class SpinnerRight
end

end #module GGLib
