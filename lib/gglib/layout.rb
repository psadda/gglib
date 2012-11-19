module GGLib

class Layout
  include Volatile

  def initialize
    @events = {}
  end

  def align(container, children)
  end
end

class FreeLayout < Layout
  def align(container, children)
    x_max = 0
    y_max = 0
    children.each do |child|
      x_max = child.x2 if child.x2 > x_max
      y_max = child.y2 if child.y2 > y_max
    end
    if y_max > container.y2
      case container.style.vertical_overflow
        when Overflow::Auto, Overflow::Hide
          #begin clipping
        when Overflow::Show
          #do nothing
        when Overflow::Stretch
          #resize container
        when Overflow::Scroll
          #create scrollbar
      end
    end
    if x_max > container.x2
      case container.style.horizontal_overflow
        when Overflow::Auto, Overflow::Hide
          #begin clipping
        when Overflow::Show
          #do nothing
        when Overflow::Stretch
          #resize container
        when Overflow::Scroll
          #create scrollbar
      end
    end
    return [x_max, y_max]
  end
end

class RelativeLayout < Layout
  def align(container, children)
    unless container.has_field?(:'GGLib.RelativeLayout/last-position')
      container.set_field(:'GGLib.RelativeLayout/last-position', [container.x, container.y])
      container.set_field(:'GGLib.RelativeLayout/known-children', {})
    end
    last_position = container.get_field(:'GGLib.RelativeLayout/last-position')
    known_children = container.get_field(:'GGLib.RelativeLayout/known-children')
    x_max = 0
    y_max = 0
    deltax = container.x1 - last_position[0]
    deltay = container.x1 - last_position[1]
    children.each do |child|
      if known_children.has_key?(child)
        child.x += deltax
        child.y += deltay
      else
        known_children[child] = true
      end
      x_max = child.x2 if child.x2 > x_max
      y_max = child.y2 if child.y2 > y_max
    end
    if y_max > container.y2
      case container.style.vertical_overflow
        when Overflow::Auto, Overflow::Hide
          #begin clipping
        when Overflow::Show
          #do nothing
        when Overflow::Stretch
          #resize container
        when Overflow::Scroll
          #create scrollbar
      end
    end
    if x_max > container.x2
      case container.style.horizontal_overflow
        when Overflow::Auto, Overflow::Hide
          #begin clipping
        when Overflow::Show
          #do nothing
        when Overflow::Stretch
          #resize container
        when Overflow::Scroll
          #create scrollbar
      end
    end
    return [x_max, y_max]
  end  
end

class VerticalLayout < Layout
  def align(container, children)
    return [0, 0] if children.empty?

    x_min = container.x1 + container.style.padding.left
    y_min = container.y1 + container.style.padding.top
    x_position = x_min
    y_position = y_min
    x_max = container.x2 - container.style.padding.right
    y_max = container.y2 - container.style.padding.bottom
    largest_x = 0
    x_width = 0
    children.each do |child|
      next if child.floating?
      if y_position + child.style.margin.top + child.height + child.style.margin.bottom > y_max
        #y overflow
        case container.style.vertical_overflow
          when Overflow::Auto
          #next column
            y_position = y_min
            x_position += largest_x
          when Overflow::Show
            #do nothing
          when Overflow::Stretch
            #resize container
          when Overflow::Hide
            #begin clipping
          when Overflow::Scroll
            #create scrollbar
        end
        if x_position > x_max
          #x overflow
          case container.style.horizontal_overflow
            when Overflow::Auto, Overflow::Hide
              #begin clipping
            when Overflow::Show
              #do nothing
            when Overflow::Stretch
              #resize container
            when Overflow::Scroll
              #create scrollbar
            end
            largest_x = 0
        end
      end
      #insert child
      y_position += child.style.margin.top
      child.move(x_position + child.style.margin.left, y_position) unless child.floating?
      y_position += child.height
      y_position += child.style.margin.bottom
      x_width = child.style.margin.left + child.width + child.style.margin.right
      largest_x = x_width if x_width > largest_x
    end
    return [x_position, y_position]
  end
end

class HorizontalLayout < Layout
  def align(container, children)
    return [0, 0] if children.empty?

    x_min = container.x1 + container.style.padding.left
    y_min = container.y1 + container.style.padding.top
    x_position = x_min
    y_position = y_min
    x_max = container.x2 - container.style.padding.right
    y_max = container.y2 - container.style.padding.bottom
    largest_y = 0
    y_height = 0
    children.each do |child|
      if x_position + child.style.margin.left + child.width + child.style.margin.right > x_max
        #x overflow
        case container.style.horizontal_overflow
          when Overflow::Auto
            #next row
            x_position = x_min
            y_position += largest_y
          when Overflow::Show
            #do nothing
          when Overflow::Stretch
            #resize container
          when Overflow::Hide
            #begin clipping
          when Overflow::Scroll
            #create scrollbar
        end
        if y_position > y_max
          #y overflow
          case container.style.vertical_overflow
            when Overflow::Auto, Overflow::Hide
              #begin clipping
            when Overflow::Show
              #do nothing
            when Overflow::Stretch
              #resize container
            when Overflow::Scroll
              #create scrollbar
            end
            largest_y = 0
        end
      end
      #insert child
      x_position += child.style.margin.left
      child.move(x_position, y_position + child.style.margin.top) unless child.floating?
      x_position += child.width
      x_position += child.style.margin.right
      y_height = child.style.margin.top + child.height + child.style.margin.bottom
      largest_y = y_height if y_height > largest_y
    end
    return [x_position, y_position]
  end
end

module Layouts
  Free = FreeLayout.new
  Relative = RelativeLayout.new
  Vertical = VerticalLayout.new
  Horizontal = HorizontalLayout.new
end

end #module GGLib
