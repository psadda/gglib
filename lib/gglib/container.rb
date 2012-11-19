module GGLib

#
# A Container is a Widget that can be populated with other Widgets.
#
module Container

  include Widget
  include Enumerable

  attr_reader :children
  attr_reader :vertical_scrollbar, :horizontal_scrollbar
  attr_accessor :auto_z_order
  attr_accessor :layout
  attr_bool :auto_z_order

  @@default_style = ContainerStyle.new
  @@default_layout = Layouts::Free

  def Container.default_style
    return @@default_style
  end

  def Container.default_style=(val)
    return (@@default_style = val)
  end

  def Container.default_layout
    return @@default_layout
  end

  def Container.default_layout=(val)
    return (@@default_layout = val)
  end

  def initialize
    @children = []
    @events = {}
    @coords = [0, 0]
    @vertical_scrollbar = @horizontal_scrollbar = nil
    @auto_z_order = true
    self.layout = @@default_layout
    super
    self.style = @@default_style.dup
  end

  #
  # Defined in Enumerable.
  #
  def entries
    return @children
  end

  # Defined in Enumerable.
  def to_a
    return @children
  end

  #
  # Add a Widget to the Container. The Widget can itself be a Container.
  #
  def add(widget)
    signal(:modified, :children)
    widget.subscribe(:modified, self.object_id) do
      signal(:modified, :children)
    end
    widget.set_container(self)
    return @children.push(widget)
  end

  def z=(value) #:nodoc: (This is an attribute)
    if @auto_z_order
      delta = value - @z
      @children.each do |child|
        child.z += delta
      end
    end
    return (@z = value)
  end

  #
  # Remove all of the children of this Container.
  #
  def clear
    @children.each do |child|
      child.unsubscribe(:modified, self.object_id)
      child.unset_container(self)
    end
    damage(:children)
  end

  #
  # Remove the given Widget from the Container. 
  # Returns the Widget if it was found and removed successfully or nil
  # if it could not be found within the Container.
  #
  def remove(widget)
    ret_value = @children.delete(widget)
    unless ret_value.nil?
      widget.unsubscribe(:modified, self.object_id)
      widget.unset_container(self)
      damage(:children)
    end
    return ret_value
  end

  #
  # Remove the given Widget from the Container. 
  # Returns the Widget if it was found and removed successfully or nil
  # if it could not be found within the Container.
  #
  # Unlike remove, recursive_remove searches not only the those
  # Widgets that are directly contained by this container, but also
  # those that are indirectly contained by this container through
  # multiple levels of nesting.
  #
  def recursive_remove(widget)
    @children.each do |child|
      if child.kind_of?(Container)
        return widget unless child.recursive_remove(widget).nil?
      elsif widget == child
        ret_value =  @children.delete(widget)
        unless ret_value.nil?
          widget.unsubscribe(:modified, self.object_id)
          widget.unset_container(self)
          damage(:children)
        end
        return ret_value
      end
    end
    return nil
  end

  #
  # Returns true if this Container contains no Widgets, false
  # otherwise.
  #
  def empty?
    return @children.empty?
  end

  #
  # Returns true if the given Widget is contained in this Container,
  # false otherwise.
  #
  def contains?(widget)
    return (not @children.index(widget).nil?)
  end

  #
  # Returns true if the given Widget is contained in this Container,
  # false otherwise.
  #
  # Unlike contains?, recursive_contains? searches not only those 
  # Widgets that are immediately contained by the Container, but 
  # also those that are indirectly contained by this container
  # through multiple levels of nesting.
  #
  def recursive_contains?(widget)
    @children.each do |child|
      if child.kind_of?(Container)
        return true if child.recursive_contains(widget)
      elsif widget == child
        return true
      end
    end
    return false
  end

  #
  # Iterates over all of the Widgets contained by this Container.
  #
  def each
    @children.each do |widget|
      yield widget
    end
    return nil
  end

  #
  # Iterates over all of the Widgets contained by this Container.
  #
  # Unlike each, recursive_each yields not only those Widgets
  # that are immediately contained by the Container, but also those
  # that are indirectly contained by this container through multiple 
  # levels of nesting.
  #
  def recursive_each
    @children.each do |widget|
      yield widget
      if widget.kind_of?(Container)
        widget.recursive_each do |nested_widget|
          yield nested_widget
        end
      end
    end
    return nil
  end

  #
  # Give the specified child Widget the highest z order of any of the children.
  # This will cause the Widget to appear on top of any overlapping siblings.
  #
  def bring_child_to_front(child)
    return nil unless (child.parent == self)
    max_z = 0
    @children.each do |widget|
      max_z = widget.z if max_z > widget.z
    end
    child.z = max_z + 0.1
    return child.z
  end

  #
  # Give the specified child Widget the lowest z order of any of the children.
  # This will cause the Widget to appear underneath any overlapping siblings.
  #
  def send_child_to_back(child)
    return nil unless (child.parent == self)
    min_z = 0
    @children.each do |widget|
      min_z = widget.z if min_z > widget.z
    end
    child.z = min_z - 0.1
    return child.z
  end

  def update
    @children.each do |child|
      child.update
    end
    return super
  end

  def draw
    damaged = self.damaged? # Calling super will reset this variable, so save the current value
    visible = super

    if visible
      @coords = realign_children if damaged

      if clip
        @window.backend.draw_clipped(
          @x1 + @style.padding.left,
          @y1 + @style.padding.top,
          @clip_right,
          @clip_bottom
        ) do
          @children.each do |widget|
            widget.draw
          end
        end
      else
        @children.each do |widget|
          widget.draw
        end
      end

    end

    return visible
  end

  private
  def clip
    do_clip = false
    @clip_right = @window.width
    @clip_bottom = @window.height

    if @coords[0] > @x2 - @style.padding.right
      case @style.horizontal_overflow
        when Overflow::Auto
          #do nothing; layout has already taken care of this
        when Overflow::Show
          #do nothing
        when Overflow::Stretch
          #resize container
        when Overflow::Hide
          do_clip = true
          @clip_right = @x2 - @style.padding.right
        when Overflow::Scroll
          do_clip = true
          @clip_right = @x2 - @style.padding.right
      end
    end

    if @coords[0] > @y2 - style.padding.bottom
      case @style.vertical_overflow
        when Overflow::Auto
          #do nothing; layout has already taken care of this
        when Overflow::Show
          #do nothing
        when Overflow::Stretch
          #resize container
        when Overflow::Hide
          do_clip = true
          @clip_bottom = @y2 - @style.padding.bottom
        when Overflow::Scroll
          do_clip = true
          @clip_bottom = @y2 - @style.padding.bottom
      end
    end

    return do_clip
  end

  public
  def set_container(object) #:nodoc: (This is an implementation detail)
    # The new parent of this container may be in a different window.
    # In order to propagate this new window to all of the children,
    # call the set_conainer function on all children.
    ret = super
    @children.each do |child|
      child.set_container(self)
    end
    return ret
  end

  private
  def realign_children
    return @layout.align(self, @children)
  end

  attr_volatile :layout

end

#
# CustomContainer is a convenience class meant to ease the process of
# creating new Containers by acting as a base class for all new Containers.
# It is not necessary to derive from CustomContainer to create a new
# Container. All that is necessary is to include the module Container.
#
class CustomContainer
  include Container
end

#
# A CompoundWidget is a widget composed of many sub-widgets. An example
# is a scrollbar, which could have sub-widgets for the two scroll arrows, the
# dragable bar, and so on. A CompoundWidget is a Widget wrapped around a
# Container that can be used to hold the sub-widgets.
#
module CompoundWidget

  include Widget

  attr_reader :container

  def initialize
    super
    @container = CustomContainer.new
    @auto_size_container = true
    @container.on :modified do
      self.damage
    end
  end

  def update
    super
    @container.update
  end

  def set_container(container) #:nodoc:
    @container.set_container(container)
    @container.float
    return super
  end

  # TODO: is the private statement below actually necessary?
  #private
  def auto_size_container?
    return @auto_size_container
  end

  def auto_size_container
    return @auto_size_container
  end

  def auto_size_container=(val)
    self.damage unless val == @auto_size_container
    return (@auto_size_container = val)
  end

  public
  def draw
    if damaged? and @auto_size_container
      @container.set_region(@x1, @y1, @x2, @y2)
      @container.z = @z
    end
    visible = super
    @container.draw if visible
    return visible
  end

end

#
# CustomCompoundWidget is a convenience class meant to ease the process of
# creating new CompoundWidgets by acting as a base class for all new CompoundWidgets.
# It is not necessary to derive from CustomCompoundWidget to create a new
# CompoundWidget. All that is necessary is to include the module CompoundWidget.
#
class CustomCompoundWidget
  include CompoundWidget
end

end
