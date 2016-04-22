require 'cleanroom'
# Generates cleanroom methods corresponding to all the xml_accessors and plain_accessors of @el
class BaseCleanroom
  include Cleanroom
  def get_el
    @el
  end

  def initialize(el, runtime)
    @runtime = runtime
    @el = el
    get_el.attributes.each do |attr|
      method_name = attr.accessor.to_sym
      create_method(method_name) do |name = nil, &block|
        if !block.nil?
          clazz = name ? @runtime.fetch(name) : attr.sought_type
          value = expand(clazz, &block)
        elsif name
          value = name
        else
          return get_el.send(attr.accessor.to_sym)
        end

        if attr.array?
          array_attr = get_el.send(attr.accessor.to_sym)
          array_attr ||= attr.default
          array_attr << value
          get_el.send(attr.setter.to_sym, array_attr)
        else
          get_el.send(attr.setter.to_sym, value) unless get_el.send(attr.accessor.to_sym)
        end
      end
      self.class.send(:expose, method_name)
    end

    expose_attr_accessors
  end

  def expose_attr_accessors()
    get_el.class.plain_accessors.each do |a|
      create_method(a) do |value = nil|
        return get_el.send(a) unless value
        get_el.send("#{a}=".to_sym, value) if value
      end
      self.class.send(:expose, a)
    end
  end
  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def expand(clazz, &block)
    plain_accessors = @el.class.plain_accessors
    hash = {}
    @value_holder ||= {}
    hash = plain_accessors.inject({}) {|h, a| h[a] = @el.send(a); h}
    child = @runtime.create_cleanroom(clazz)
    child.inherit_properties hash.merge(@value_holder)

    child.evaluate &block
    new_values = child.value_holder
    append_child_modifications new_values
    child.get_el.process.each {|proc| child.evaluate &proc } if child.get_el.respond_to? :process

    child.get_el
  end

  def append_child_modifications(hash)
    hash.each do |k, v|
      setter = "#{k}="
      get_el.send(setter, v) if get_el.respond_to? setter
    end

    @value_holder.merge! hash
  end

  attr_reader :value_holder
  def inherit_properties(props)
    @value_holder = props
    props.each do |name, val|

      self.instance_variable_set("@#{name}", val)
      create_method name do |value = nil|
        # self.instance_variable_set("@#{name}", value) if value
        # instance_variable_get "@#{name}"
        @value_holder[name] = value if value
        @value_holder[name]
      end
      self.class.send(:expose, name)
    end
  end
end