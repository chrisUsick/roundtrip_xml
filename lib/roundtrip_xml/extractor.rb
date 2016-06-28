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
      ROXMLDiff.new diff[0], diff[1], from_hash(diff[2]), diff[3]
    end

    diffs
  end

  def from_hash(hash)
    return hash unless hash.is_a? Hash
    @runtime.fetch(hash['__class']).from_hash @runtime, hash

  end

  def convert_roxml_objs
    def_names = @definitions.keys
    @roxml_objs.map do |obj|
      convert_roxml_obj obj
    end
  end

  def convert_roxml_obj (obj)
    name = obj.class.class_name
    defs = @definitions[name]

    defs.each do |defin|
      diffs = diff_definition(defin, obj)
      if diffs.all? {|diff| diff.operation == '~' && (diff.template_val.is_a?(Utils::UndefinedParam) || diff.template_val == nil) }
        new_obj = defin.class.new
        param_values = diffs.inject({}) do |values, diff|
          name = diff.template_val ? diff.template_val.name : diff.key
          values[name] = diff.obj_val
          values
        end
        set_attributes new_obj, param_values
        # return convert_roxml_obj new_obj
        obj = new_obj
      end
    end if defs

    obj.class.roxml_attrs.each do |a|
      if a.array?
        elements = a.sought_type.class == Class ?
          obj.send(a.accessor).map {|el| convert_roxml_obj el} : obj.send(a.accessor)
        obj.send a.setter.to_sym, elements
      elsif a.sought_type.class == Class
        current_value = obj.send(a.accessor)
        obj.send a.setter.to_sym, convert_roxml_obj(current_value) if current_value
      end
    end
    obj
  end

  def set_attributes(obj, params)
    params.each do |param, val|
      methods = param.to_s.split '.'
      methods << val
      set_deep_attributes obj, methods
      # obj.send "#{param}=", val
    end

  end

  def set_deep_attributes(obj, methods)
    index = methods[0].match(/\[(\d+)\]/)
    child = index ? nil : obj.send(methods[0])
    method = methods[0]
    method.gsub!(/\[\d+\]/, '')
    if child
      set_deep_attributes child, methods[1..methods.size]
    else
      if index
        arr = obj.send(method) || []
        arr[Integer(index[1])] = methods[1..1][0] # hacky way to get second element
        obj.send("#{method}=", arr)
      else
        obj.send(methods[0] + '=', set_deep_attributes_helper(obj, methods))
      end
    end
  end

  def set_deep_attributes_helper(obj, methods)
    method = methods.shift
    index = method.match(/\[(\d+)\]/)
    return obj.send(method + '=', methods.first) if !index && methods.size == 1

    method.gsub!(/\[\d+\]/, '')
    child = obj.send(method)
    unless child || methods.size == 1
      clazz_name = method.dup
      clazz_name[0] = clazz_name[0].upcase
      child = @runtime.fetch(clazz_name.to_sym).new
      obj.send("#{method}=", child)

    end
    if index
      arr = obj.send(method) || []
      arr[Integer(index[1])] = methods.first
      obj.send("#{method}=", arr)
    else
      obj.send(method + '=', set_deep_attributes_helper(child, methods))
    end

    child.is_a?(Array) ? obj : child || obj
  end

end

class ROXMLDiff
  attr_reader :operation, :key, :obj_val, :template_val
  def initialize(operation, key, obj_val, template_val)
    @operation = operation
    @key = key.to_sym
    @obj_val = obj_val
    @template_val = template_val
  end
end