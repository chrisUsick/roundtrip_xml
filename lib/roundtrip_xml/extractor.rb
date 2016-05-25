require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/utils'
require 'hashdiff'
require 'set'
require 'roundtrip_xml/utils'
require 'multiset'
require 'roundtrip_xml/roxml_subclass_helpers.rb'

class Extractor

  def initialize(roxml_objs, runtime, root_class, definitions = nil, &block)
    @roxml_objs = roxml_objs
    @runtime = runtime
    @root_class = root_class
    if block_given?
      @definitions = eval_definitions root_class, &block
    elsif definitions.is_a? Hash
      @definitions = definitions
    else
      @definitions = eval_definitions root_class, definitions
    end
  end

  def eval_definitions(root_class, str = nil, &block)
    old_names = @runtime.instance_variable_get(:@classes).keys
    if block_given?
      @runtime.evaluate_raw '', root_class, &block
    else
      @runtime.evaluate_raw str, root_class
    end
    new_names = @runtime.instance_variable_get(:@classes).keys
    def_names = new_names - old_names
    def_names.inject({}) do |out, name|
      clazz = @runtime.fetch(name)
      parent = get_root_class clazz
      obj = clazz.new
      cleanroom = @runtime.create_cleanroom clazz, true
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
    [def_hash, obj_hash].each do |h|
      h.delete '__class'
    end
    diffs = HashDiff.diff(obj_hash, def_hash).map do |diff|
      ROXMLDiff.new diff[1], from_hash(diff[2]), diff[3]
    end

    diffs
  end

  def from_hash(hash)
    return hash unless hash.is_a? Hash
    @runtime.fetch(hash['__class']).from_hash @runtime, hash

  end

  def convert_roxml_objs
    def_names = @definitions.keys
    roxml_objs.map do |obj|
      convert_roxml_obj obj
    end
  end

  def convert_roxml_obj (obj)
    name = obj.class.class_name
    defs = @definitions[name]
    return obj unless defs && defs.size > 0
    defs.each do |defin|
      diffs = diff_definition(defin, obj)
      if diffs.all? {|diff| diff.template_val.is_a?(Utils::UndefinedParam) || diff.template_val == nil }
        new_obj = defin.class.new
        param_values = diffs.inject({}) do |values, diff|
          name = diff.template_val ? diff.template_val.name : diff.key
          values[name] = diff.obj_val
          values
        end
        set_attributes new_obj, param_values
        return new_obj
      else
        return obj
      end
    end
  end

  def set_attributes(obj, params)
    params.each do |param, val|
      methods = param.to_s.split '.'
      # set_deep_attribute obj, methods, val
      obj.send "#{param}=", val
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