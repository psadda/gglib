module GGLib

class Progress

  include CompoundWidget

  attr_accessor :range, :value

  theme_class :progress_bar

  def initialize(range = 0..100, value = 0)
    super()
    @range = range
    @value = value
    @throbber = false
    @fill = ProgressFill.new
    @container.style.renderer = nil
  end

  def value=(val)
    @value = val
    @throbber = (@value == :unknown)
    return @value
  end

end

class ProgressFill

  include Widget

  theme_class :progress_fill

end

end
