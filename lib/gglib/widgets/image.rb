module GGLib

#
# Image is a very simple Widget that displays an image file.
#
# Image.new('image.png')
#
class Image
  include Widget

  def initialize(image)
    super
    self.image = image
  end
end

end #module GGLib
