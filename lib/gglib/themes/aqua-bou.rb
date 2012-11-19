module GGLib

class AquaBou < CustomTheme

  def initialize
    aquabou_root = '../media/themes/aqua-bou/widgets/'
    @renderers = {

      :button => GGLib.grid9renderer(
        aquabou_root + 'button',
        GGLib.states(:enabled, :disabled, :focused, :active, :down),
        GGLib.margin(0, -15, -35, -11),
        GGLib.padding(-10, 0, -10, 0)
      ),

      :scroll_bar => GGLib.grid9renderer(
        aquabou_root + 'scroll/bar',
        GGLib.states(:enabled),
        GGLib.margin(-1, -1, -2, -1),
        GGLib.padding()
      ),

      :scroll_vgrip => GGLib.grid9renderer(
        aquabou_root + 'scroll/grip/vertical',
        GGLib.states(:enabled, :focused),
        GGLib.margin(-5, -5, -5, 0),
        GGLib.padding()
      ),

      :scroll_hgrip => GGLib.grid9renderer(
        aquabou_root + 'scroll/grip/horizontal',
        GGLib.states(:enabled, :focused),
        GGLib.margin(-1),
        GGLib.padding()
      ),

      :scroll_uparrow => GGLib.grid9renderer(
        aquabou_root + 'scroll/arrow/up',
        GGLib.states(:enabled, :focused, :down),
        GGLib.margin(0, 0, -9, 0),
        GGLib.padding()
      ),

      :scroll_downarrow => GGLib.grid9renderer(
        aquabou_root + 'scroll/arrow/down',
        GGLib.states(:enabled, :focused, :down),
        GGLib.margin(-9, 0, 0, 0),
        GGLib.padding()
      ),

      :scroll_leftarrow => GGLib.grid9renderer(
        aquabou_root + 'scroll/arrow/left',
        GGLib.states(:enabled, :focused),
        GGLib.margin(),
        GGLib.padding()
      ),

      :scroll_rightarrow => GGLib.grid9renderer(
        aquabou_root + 'scroll/arrow/right',
        GGLib.states(:enabled, :focused),
        GGLib.margin(),
        GGLib.padding()
      ),

      :line_edit => GGLib.grid9renderer(
        aquabou_root + 'line-edit',
        GGLib.states(:enabled),
        GGLib.margin(0, -15, -35, -11),
        GGLib.padding(-10, 0, -10, 0)
      ),

      :default => GGLib.grid9renderer(
        aquabou_root + 'button',
        GGLib.states(:enabled, :disabled),
        GGLib.margin(0, -15, -35, -11),
        GGLib.padding(-10, 0, -10, 0)
      )
    }
  end
end

module Themes
  AquaBou = GGLib::AquaBou.new
end

end #module
