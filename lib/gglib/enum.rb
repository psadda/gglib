module GGLib

class Enumeration < Module

  include Enumerable

  def initialize(*elements)
    elements = elements[0] if elements.size == 1
    @elements = elements
    @syn = { }
    @elements.each do |e|
      if e[0].downcase != e[0]
        self.const_set(e.to_s, e)
      else
        s = e.to_s
        words = s.split('_')
        words.map! { |word| word.capitalize }
        s = words.join
        self.const_set(s, e)
      end
    end
  end

  def elements
    return @elements
  end

  def alias(element_alias, element)
    return false if @elements.index(element).nil?
    @syn[element_alias] = element
    return element_alias
  end

  def include?(item)
    return true if @syn.has_key?(item)
    return (not @elements.index(item).nil?)
  end

  def value_of(item)
    return @syn[item] if @syn.has_key?(item)
    return item if @elements.index(item).nil?
    return nil
  end

  def each
    @elements.each do |e|
      yield e
    end
  end

end

def GGLib.enum(*params)
  return Enumeration.new(*params)
end

end
