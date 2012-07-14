module GGLib

#
#A StateObject is a menu. It suspends the game and redirects all input to itself.
#StateObject is typically used through derivation, although it can be used otherwise.
#StateObject#start suspends the game and starts the menu. StateObject#end returns to the game.
#

class StateObject

  #
  # Begin rerouting input to the StateObject. DO NOT OVERRIDE THIS METHOD.
  #
  def enter
    start
  end

  #
  # Return control to the StateObject. DO NOT OVERRIDE THIS METHOD.
  #
  def exit
    stop
    $window.deleteAllWidgets
    $window.createWidgets
    $window.deleteAllImages
    $window.cursor.unforceVisible
    terminate
  end

  #
  # Equivalent to Gosu::Window#button_down
  #
  def button_down(id)
  end

  #
  # Equivalent to Gosu::Window#button_down
  #
  def button_up(id)
  end

  #
  # Equivalent to Gosu::Window#update
  #
  def update
  end

  #
  # This method is called when the static screen is initialized. It is ment to be overridden in derived classes.
  # This is a good place to preform tasks such as creating widgets.
  #
  def start
  end

  #
  #This method is called when the static screen is uninitialized. It is ment to be overridden in derived classes.
  #This is a good place to preform tasks such as stopping audio. Widgets are automatically destroyed on exit by the base class StaticScreen
  #
  def stop
  end

  def terminate
  end

  #
  # Equivalent to Gosu::Window#draw
  #
  def draw
  end
end

class FadeScreen < StateObject
  public
  attr_reader :widgetID
  def initialize(fadeTo=nil, speed=1)
    $faded=false
    @image=Gosu::Image.new($window, $gglroot+"/media/black.bmp", true)
    @fading=false
    @speed=speed
    @fadeTo=fadeTo
    @color=Gosu::Color.new(0xffffffff)
  end
  def fading?
    return @fading
  end
  def onStart
    @fading=true
    @alpha=0
  end
  def draw
    if @fading
      @alpha+=@speed
      if @alpha > 255
        @alpha=255
      end
      @color.alpha=@alpha
      @image.draw(0, 0, ZOrder::Top+1, 640, 480, @color)
      if @alpha == 255
        endFade
        @widgetID = FadeIn.new(@speed)
      end
    end
  end
  def endFade
    @fading=false
    @image=nil
    self.end
    @fadeTo.start if @fadeTo!=nil
  end
  
  class FadeIn < CustomWidget
    def initialize(speed=5)
      @image=Gosu::Image.new($window, $gglroot+"/media/black.bmp", true)
      @speed=speed
      @color=Gosu::Color.new(0x00ffffff)
      @alpha=255
      super(:FadeIn, 0, 0, 0, 0)
      wakeUp
      stickFocus
      $window.setFocus(nil)
    end
    def draw
      @alpha-=@speed
      if @alpha < 0
        @alpha=0
      end
      @color.alpha=@alpha
      @image.draw(0, 0, ZOrder::Top+1, 640, 480, @color)
      if @alpha == 0
        endFade
      end
    end
    def endFade
      unstickFocus
      $window.setFocus(nil)
      del
      $faded=true
    end
  end
  
end

end #module GGLib
