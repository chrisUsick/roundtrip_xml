require 'roundtrip_xml/base_cleanroom'
require 'roundtrip_xml/utils'
# addes the `define` and `use_file` method to a cleanroom. Only used when evaluating a root file
class RootCleanroom < BaseCleanroom
  include Utils
  def define(name, parent, *params, &block)
    parent_class = @runtime.fetch parent
    new_class = new_roxml_class(name, parent_class) do
      self.instance_variable_set :@class_name, name
      # simply using @@params is referring to `AContainer`
      # hash = self.class_variable_defined?(:@@block) ? self.class_variable_get(:@@block) : {}
      # hash[name] = block
      self.instance_variable_set(:@block, block)
      params.each do |param|
        plain_accessor param
      end

      parent_class.plain_accessors.each do |accessor|
        plain_accessor accessor
      end

      def process
        proc = self.class.instance_variable_get(:@block)#[self.class.instance_variable_get(:@class_name)]
        if self.class.superclass.respond_to? :process
          [proc].concat self.class.superclass.process
        else
          [proc]
        end
      end
      def self.process
        proc = self.instance_variable_get(:@block)
        if self.superclass.respond_to? :process
          [proc].concat self.superclass.process
        else
          [proc]
        end

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