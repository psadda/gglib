module GGLib

#
# Button.new 'ButtonText' do |this|
#   this.text = 'I was clicked'
# end
#
class Button
  include Widget

  attr_accessor :icon

  def initialize(text = '', theme_class = :button, draggable = false, &block)
    super(theme_class)
    @text = text
    @down = false
    on :mouse_down, :left do |this|
      @dirty = true
      @down = true
    end
    on :mouse_up, :left do |this|
      @dirty = true
      @down = false
      this.deactivate
    end
    unless draggable
      on :blur do |this|
        if @down
          @dirty = true
          @down = false
          this.deactivate
        end
      end
    end
    on :mouse_up, :left, &block if block_given?
    @icon = nil
    @icon_widget = nil
  end

  def icon=(val)
    require './image'
    @icon_widget = Image.new(val)
    return (@icon = val)
  end

  def draw
    ret = super

    if not @icon_widget.nil? and @icon_widget.needs_redraw?
      @icon_widget.move @x1 + ((width - @icon_widget.width)/2).floor, @y1 + ((height - @icon_widget.height)/2).floor
      @icon_widget.draw
    end

    return ret
  end

  def down?
    return @down
  end
end

end #module GGLib
