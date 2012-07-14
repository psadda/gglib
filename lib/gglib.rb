module GGLib
  VERSION = '2.0.0'
  VERSION_MAJOR = 2
  VERSION_MINOR = 0
  VERSION_PATCH = 0

  @@default_window = nil

  def GGLib.default_window=(val)
    @@default_window = val
  end
  def GGLib.default_window
    return @@default_window
  end

end

$gglroot = File.expand_path(File.dirname(__FILE__))

require './gglib/enum'
require './gglib/event'
require './gglib/util'
require './gglib/primatives'
require './gglib/theme'
require './gglib/style'
require './gglib/widget'
require './gglib/layout'
require './gglib/container'
require './gglib/mouse'
require './gglib/backend'
require './gglib/window'
