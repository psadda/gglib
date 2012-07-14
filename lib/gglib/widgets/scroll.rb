
module GGLib

class Scroll
  #TODO
  #recalculate grip range when scrollbar is dirtied
  include CompoundWidget

  attr_accessor :value, :range, :type

  def initialize(type = :vertical, range =0..100, value = range)
    super(:invisible)
    self.range = range
    self.value = 0..30
    style.padding = Padding.new(1)
    @container.layout = Layouts::FREE
    @container.style.renderer = nil
    self.type = type
    @velocity = 1
    @old_velocity = 0
    @update_velocity = 1
    self.on :update do |this|
      @update_velocity += 1
      if @update_velocity == 10
        # Reset the velocity to one if it has not increased in the last ten frames.
        # TODO: rewrite this to use time, not frames, so that behavior is consistent across different refresh rates
        @velocity = 1 if @old_velocity == @velocity
        @update_velocity = 0
        @old_velocity = @velocity
      end
    end
  end

  public
  def range=(val)
    @range_start = val.first
    @range_end = val.last
    @range_end +=1 unless val.exclude_end?
  end
  
  def value=(val)
    @value_start = val.first
    @value_end = val.last
    @value_end +=1 unless val.exclude_end?    
  end

  private
  def init
    @bar = ScrollBar.new(self)

    if @type == :horizontal
      @increase = ScrollRight.new(self)
      @decrease = ScrollLeft.new(self)
      @grip = HorizontalScrollGrip.new(self)
    else
      @increase = ScrollDown.new(self)
      @decrease = ScrollUp.new(self)
      @grip = VerticalScrollGrip.new(self)
    end

    @container.clear
    @container.add(@decrease)
    @container.add(@increase)
    @container.add(@bar)
    @container.add(@grip)

    @bar.on :unbuffered_mouse_down, :left do |bar, button, x, y|
      sx = x > @grip.x2 ? 1 : -1
      sy = y > @grip.y2 ? 1 : -1
      on_grip_drag(sx * @velocity.to_i, sy * @velocity.to_i)
      @velocity += 0.2 if @velocity < 10
    end

    @grip.on :dragged do |grip, x, y|
      on_grip_drag(x, y)
    end

    @increase.on :unbuffered_mouse_down, :left do |increase|
      on_grip_drag(@velocity.to_i, @velocity.to_i)
      @velocity += 0.2 if @velocity < 10
    end

    @decrease.on :unbuffered_mouse_down, :left do |increase|
      on_grip_drag(-@velocity.to_i, -@velocity.to_i)
      @velocity += 0.2 if @velocity < 10
    end

    if @type == :horizontal
      repair_horizontal(true)
    else
      repair_vertical(true)
    end
  end

  def repair_horizontal(zero_grip = false)
    oldoff = 0
    unless zero_grip
      oldoff = @grip.x1 - @decrease.x2
    end

    self.unchecked do
      @decrease.move(self.x, self.y)
      @decrease.height = self.height

      @bar.move(@decrease.x2, self.y)
      @bar.resize(self.width - (@decrease.width + @increase.width), self.height)

      @grip.move(@decrease.x2 + oldoff, self.x + style.padding.left)
      @grip.resize(self.width - (@decrease.width + @increase.width), self.height - (self.style.padding.top + self.style.padding.bottom))

      @increase.move(self.x2 - @increase.width, self.y)
      @increase.height = self.height
    end
    size_grip
  end

  def repair_vertical(zero_grip = false)
    oldoff = 0
    unless zero_grip
      oldoff = @grip.y1 - @decrease.y2
    end

    self.unchecked do
      @decrease.move(self.x, self.y)
      @decrease.width = self.width

      @bar.move(self.x, @decrease.y2)
      @bar.resize(self.width, self.height - (@decrease.height + @increase.height))

      @grip.move(self.x + style.padding.left, @decrease.y2 + oldoff)
      @grip.resize(self.width - (self.style.padding.left + self.style.padding.right), self.height - (@decrease.height + @increase.height))

      @increase.move(self.x, self.y2 - (@increase.height))
      @increase.width = self.width
    end
    size_grip
  end

  def size_grip
    if @value_start <= @range_start and @value_end >= @range_end
      @grip.hide
      #TODO: create disabled graphics for these
      #@increase.disable
      #@decrease.disable
      return
    end

    bar_length = (@type == :horozontal)? @bar.width : @bar.height
    range_length = @range_end - @range_start
    value_length = @value_end - @value_start

    scale = value_length.to_f / range_length.to_f
    grip_length = scale * bar_length

    self.unchecked do
      if @type == :horizontal
        @grip.width = grip_length
      else
        @grip.height = grip_length
      end
    end
  end

  def on_grip_drag(x, y)

    if @type == :horizontal
      @grip.x += x
      if @grip.x < @decrease.x2
        @grip.x = @decrease.x2
      elsif @grip.x2 > @increase.x1
        @grip.x = @increase.x1 - @grip.width
      end
    else
      @grip.y += y
      if @grip.y < @decrease.y2
        @grip.y = @decrease.y2
      elsif @grip.y2 > @increase.y1
        @grip.y = @increase.y1 - @grip.height
      end
    end

    #TODO: adjust the value_start and value_end variables. Should this be done before or after size_grip?

    size_grip
  end

  def move_to_click(x, y)
  end

  public
  def type=(val)
    unless val == @type
      # Don't bother making a change if the new type is the
      # same as the old type.
      @type = val
      init
    end
    return val
  end

  def draw
    if damaged?
      if @type == :horizontal
        repair_horizontal
      else
        repair_vertical
      end
    end

    ret = super

    return ret
  end

  attr_volatile :range, :value, :type
end

class ScrollBar
  include Widget
  def initialize(parent)
    super(:scroll_bar)
    @parent = parent
  end
end

class ScrollIncrease < Button
  def initialize(parent, theme_class)
    super('', theme_class)
    @parent = parent
  end
end

class ScrollDecrease < Button
  def initialize(parent, theme_class)
    super('', theme_class)
    @parent = parent
  end
end

class ScrollUp < ScrollDecrease
  def initialize(parent)
    super(parent, :scroll_uparrow)
  end
end

class ScrollDown < ScrollIncrease
  def initialize(parent)
    super(parent, :scroll_downarrow)
  end
end

class ScrollLeft < ScrollDecrease
  def initialize(parent)
    super(parent, :scroll_leftarrow)
  end
end

class ScrollRight < ScrollIncrease
  def initialize(parent)
    super(parent, :scroll_rightarrow)
  end
end

class ScrollGrip < Button
  def initialize(theme_class)
    super('', theme_class, true)
    on :drag do |this, x, y|
      signal(:dragged, x, y) if @enabled
    end
  end
end

class VerticalScrollGrip < ScrollGrip
  def initialize(parent)
    super(:scroll_vgrip)
  end
end

class HorizontalScrollGrip < ScrollGrip
  def initialize(parent)
    super(:button)
    @parent = parent
    @range = range
    on :drag do |this, x, y|
      if self.x + x < @range.max
        self.x += x
      else
        self.x = @range.max
      end
      @parent.value += (x / ((@range.max - self.width) - @range.first)).to_i
    end
  end
  def range
    return @range
  end
  def range=(val)
    
    return (@range = val)
  end
end

end #module GGLib
