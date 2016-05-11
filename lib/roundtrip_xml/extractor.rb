require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/utils'
require 'hashdiff'
require 'set'
require 'roundtrip_xml/utils'
require 'multiset'
require 'roundtrip_xml/roxml_subclass_helpers.rb'

class Extractor

  def initialize(roxml_objs, runtime, definitions = nil, &block)
    @roxml_objs = roxml_objs
    @runtime = runtime
    if block_given?
      @definitions = eval_definitions &block
    elsif definitions.is_a? Hash
      @definitions = definitions
    else
      @definitions = eval_definitions definitions
    end
  end

  def eval_definitions(str = nil, &block)
    old_names = @runtime.instance_variable_get(:@classes).keys
    if block_given?
      @runtime.evaluate_raw '', :HealthRules, &block
    else
      @runtime.evaluate_raw str, :HealthRules
    end
    new_names = @runtime.instance_variable_get(:@classes).keys
    def_names = new_names - old_names
    def_names.inject({}) do |out, name|
      clazz = @runtime.fetch(name)
      parent = get_root_class clazz
      obj = clazz.new
      cleanroom = @runtime.create_cleanroom clazz
      cleanroom.get_el.process.each { |p| cleanroom.evaluate &p }
      out[parent] ||= []
      out[parent] << cleanroom.get_el
      out
    end
  end

  def get_root_class(clazz)
    super_clazz = @runtime.fetch clazz.superclass.class_name
    if super_clazz.subclass?
      get_root_class super_clazz
    else
      super_clazz.class_name
    end
  end

  def diff_definition(defin, obj)
    def_hash = defin.to_hash
    obj_hash = obj.to_hash
    diffs = HashDiff.diff(obj_hash, def_hash).map do |diff|
      ROXMLDiff.new diff[1], diff[2], diff[3]
    end

    diffs
  end

  def convert_roxml_objs
    def_names = @definitions.keys
    roxml_objs.map do |obj|
      name = obj.class.roxml_tag_name
      if def_names.include? name && diff(@definitions[name], obj)

      end

    end
  end
end

class ROXMLDiff
  attr_reader :key, :obj_val, :template_val
  def initialize(key, obj_val, template_val)
    @key = key.to_sym
    @obj_val = obj_val
    @template_val = template_val
  end
end