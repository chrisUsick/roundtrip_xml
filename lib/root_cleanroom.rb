require './lib/base_cleanroom'
class RootCleanroom < BaseCleanroom

  def define(name, parent, *params, &block)
    new_class = Class.new(Object.const_get parent) do
      # simply using @@params is referring to `AContainer`
      self.class_variable_set(:@@params, params)
      self.class_variable_set(:@@block, block)
      def initialize
        super
        @mixin = self.class.class_variable_get(:@@block)
        @args = self.class.class_variable_get(:@@params)
        @value_holder = create_attr_holder(@args).new

        @args.each do |arg|
          # expose setter
          create_method(arg) do |value=nil|
            return @value_holder.send(arg) if value == nil
            arg_setter = "#{arg.to_s}=".to_sym
            @value_holder.send(arg_setter, value) unless @value_holder.send(arg)
          end
          self.class.send(:expose, arg)
        end
      end


      def process
        self.evaluate(&@mixin) #.call(*params_for_mixin)
      end
    end
    Object.const_set name, new_class
  end
  expose(:define)
end