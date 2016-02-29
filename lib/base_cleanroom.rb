require 'cleanroom'
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
      create_method(method_name) do |value|
        if attr.array?
          array_attr = get_el.send(attr.name.to_sym)
          array_attr ||= attr.default
          array_attr << value
          get_el.send(attr.setter.to_sym, array_attr)
        else
          get_el.send(attr.setter.to_sym, value) unless get_el.send(attr.name.to_sym)
        end
      end
      self.class.send(:expose, method_name)
    end
  end
  def create_method(name, &block)
    self.class.send(:define_method, name, &block)
  end

  def expand(name, &block)
    child = @runtime.fetch_cleanroom(name)
    child.inherit_properties(@args, @value_holder) if instance_variable_defined?(:@args)
    child.evaluate &block
    child.process if child.respond_to? :process
    child.get_el
  end
  expose(:expand)

  def inherit_properties(props, value_holder)
    @value_holder ||= value_holder
    props.each do |arg|
      @value_holder.class.send(:attr_accessor, arg)
      @value_holder.send("#{arg}=".to_sym, value_holder.send(arg))
      create_method(arg) do
        @value_holder.send(arg)
      end
      self.class.send(:expose, arg)
    end
  end
end