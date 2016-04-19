require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/utils'
require 'hashdiff'
require 'set'
require 'roundtrip_xml/utils'
require 'multiset'

class Extractor
  include Utils
  def initialize(roxml_objs, runtime)
    @roxml_objs = roxml_objs
    @hashes = @roxml_objs.map { |obj| obj.to_hash }
    @runtime = runtime
    @subclass_names = Multiset.new
    @SUFIX = '_v'.freeze
  end
  def list_diffs

    HashDiff.best_diff(@hashes[0], @hashes[6]).sort_by do |diff|
      m = diff[1].match(/\./)
      m ? m.size : 0
    end.map {|diff| diff[1]}
  end

  def similar_fields
    keys = Set.new @hashes[0].keys
    diff_keys = Set.new
    @hashes.each do |hash_1|
      @hashes.each do |hash_2|
        diffs = HashDiff.best_diff(hash_1, hash_2).map do |diff|
          diff[1].match(/(\w+)\.?/)[1]
        end
        diff_keys.merge diffs
      end
    end
    [keys - diff_keys, diff_keys]
  end

  def create_romxl_class(keys, parent)
    @subclass_names << parent
    name = "#{parent.to_s}#{@subclass_names.count(parent)}"
    clazz = new_roxml_class name, @runtime.fetch(parent)
    keys.each do |key|
      clazz.plain_accessor "#{key.to_s}#{@SUFIX}".to_sym
    end
    @runtime.add_class name, clazz
    name
  end

  def convert_roxml(obj, keys, class_name)
    parent = @runtime.fetch(class_name)
    new = parent.new
    parent.plain_accessors.each do |new_accessor|
      old_accessor = new_accessor.to_s.gsub(@SUFIX, '').to_sym
      new.send "#{new_accessor}=", obj.send(old_accessor)
    end

    keys.each do |accessor|
      new.send "#{accessor}=", obj.send(accessor)
    end
    new
  end

  def convert_roxml_objs
    fields, diff_keys = similar_fields
    parent_name = name_to_sym @roxml_objs[0].class.instance_variable_get(:@roxml_tag_name)
    name = create_romxl_class fields, parent_name
    @roxml_objs.map do |roxml|
      convert_roxml roxml, diff_keys, name
    end
  end
end