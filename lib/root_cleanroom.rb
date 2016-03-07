require './lib/base_cleanroom'
class RootCleanroom < BaseCleanroom

  def define(name, parent, *params, &block)
    new_class = Class.new(@runtime.fetch parent) do
      # simply using @@params is referring to `AContainer`
      self.class_variable_set(:@@block, block)
      params.each do |param|
        plain_accessor param
      end

      def process
        self.class.class_variable_get(:@@block)
      end
    end
    @runtime.add_class name, new_class
  end
  expose(:define)

  def use_file(path)
    self.evaluate_file(path)
  end
  expose(:use_file)
end