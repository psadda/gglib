module GGLib

  VERSION = '1.9.0'
  VERSION_MAJOR = 1
  VERSION_MINOR = 9
  VERSION_PATCH = 0

  @@default_window = nil
  @@backend = nil

  def GGLib.default_window=(val) #:nodoc: (This is an implementation detail)
    return (@@default_window = val)
  end

  def GGLib.default_window #:nodoc: (This is an implementation detail)
    return @@default_window
  end

  def GGLib.backend=(val) #:nodoc: (This is an implementation detail)
    return (@@backend = val)
  end

  def GGLib.backend #:nodoc: (This is an implementation detail)
    return @@default_window
  end

  def GGLib.default_theme=(val)
    Widget.default_style.theme = val
    Container.default_style.theme = val
  end

  def GGLib.default_widget_style=(val)
    Widget.default_style = val
  end

  def GGLib.default_container_style=(val)
    Container.default_style = val
  end

  def GGLib.default_layout=(val)
    Container.default_layout = val
  end

end

$gglroot = File.expand_path(File.dirname(__FILE__))

require $gglroot+'/gglib/enum'
require $gglroot+'/gglib/event'
require $gglroot+'/gglib/buttons'
require $gglroot+'/gglib/util'
require $gglroot+'/gglib/primatives'
require $gglroot+'/gglib/theme'
require $gglroot+'/gglib/style'
require $gglroot+'/gglib/widget'
require $gglroot+'/gglib/layout'
require $gglroot+'/gglib/container'
require $gglroot+'/gglib/mouse'
require $gglroot+'/gglib/backend'
require $gglroot+'/gglib/window'
