module GGLib

class Label

  include Widget

  theme_class :invisible

  def initialize(text = '')
    super
    @text = text
    @owner = nil
    self.on :focus do |this|
      @owner.focus unless @owner.nil?
    end
    self.on :click do |this|
      @owner.focus unless @owner.nil?
    end
  end

  def set_owner(widget) #:nodoc: (This is an implementation detail)
    @owner = widget
  end

  def unset_owner(widget) #:nodoc: (This is an implementation detail)
    @owner = nil if widget == @owner
  end

end

end #module GGLib
