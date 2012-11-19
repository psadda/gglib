class Object

  def attr_bool(*attrs)
    attrs.each do |attr|
      alias_method "#{attr}?".to_sym, attr
    end
  end

  def attr_volatile(*attrs)
    #TODO: rewrite subscribe/unsubscribe so that subscribe returns a handle that can be passed to unsubscribe.
    attrs.each do |attr|

      alias_method "atvolasgn_#{attr}".to_sym, "#{attr}=".to_sym

      define_method("#{attr}=".to_sym) do |new_val|
        attr_val = instance_variable_get("@#{attr}")
        return new_val if new_val == attr_val

        if attr_val.kind_of?(GGLib::Volatile)
          attr_val.unsubscribe :modified, self.object_id
        end

        damage(attr) if self.kind_of?(GGLib::Volatile)

        if new_val.kind_of?(GGLib::Volatile) and self.kind_of?(GGLib::Volatile)
          new_val.subscribe :modified, self.object_id do
            damage(attr)
          end
        end

        return send("atvolasgn_#{attr}".to_sym, new_val)
      end

    end
  end

end

module GGLib

module Volatile
  include Publisher

  @volatile_initd = false

  def init_volatile
    @set_damage = true
    @report_damage = true
    @damaged = false
    @volatile_initd = true
    @level_unchecked = 0
    @level_unreported = 0
  end

  # Don't set damage, don't raise modified event.
  def unchecked
    init_volatile unless @volatile_initd
    @set_damage = false
    @report_damage = false
    @level_unchecked += 1
    yield
    @level_unchecked -= 1
    if @level_unchecked <= 0
      @set_damage = true
      if @level_unreported <= 0
        @report_damage = true
      end
    end
  end

  # Don't raise modified event.
  def unreported
    init_volatile unless @volatile_initd
    @report_damage = false
    @level_unreported += 1
    yield
    @level_unreported -= 1
    if @level_unreported  <= 0 and @level_unchecked <= 0
      @report_damage = true
    end
  end

  def damage(region = nil)
    init_volatile unless @volatile_initd
    if @set_damage
      @damaged = true
      signal(:modified, region) if @report_damage
    end
    return @set_damage
  end

  def clear_damage
    init_volatile unless @volatile_initd
    @damaged = false
  end

  def update_volatile
    init_volatile unless @volatile_initd
    @damaged = false
  end

  attr_reader :damaged
  attr_bool :damaged
end

module MetadataStore
  def has_field?(field)
    @metadata = { } if @metadata.nil?
    return @metadata.has_key?(field.to_sym)
  end

  def delete_field(field)
    @metadata = { } if @metadata.nil?
    return @metadata.delete(field.to_sym)
  end

  def set_field(field, value)
    @metadata = { } if @metadata.nil?
    return @metadata[field.to_sym] = value
  end

  def get_field(field)
    @metadata = { } if @metadata.nil?
    return @metadata[field.to_sym]
  end
end

end #module GGLib
