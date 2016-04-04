require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/roxml_builder'
require 'roundtrip_xml/root_cleanroom'
require 'roundtrip_xml/base_cleanroom'
require 'roundtrip_xml/utils'
require 'tree'
# Class which evaluates DSL and read XML files to populate the namespace with classes
class DslRuntime
  include Utils
  def initialize()
    @classes = {}
    @root_classes = []
  end
  def populate(files)
    files.each {|f| populate_from_file f }
  end

  def populate_from_file (file)
    populate_raw File.read(file)

  end

  def populate_raw (raw)
    builder = RoxmlBuilder.new (Nokogiri::XML(raw).root), @classes
    new_classes = builder.build_classes
    @root_classes << builder.root_class_name
    @classes.merge! new_classes
  end


  def fetch(class_name)
    @classes[class_name]
  end

  def add_class(name, clazz)
    @classes[name] = clazz
  end

  def evaluate_file(path, root_class)
    cleanroom = RootCleanroom.new(fetch(root_class).new, self)
    cleanroom.evaluate_file path

  end

  def evaluate_raw(dsl, root_class)
    cleanroom = RootCleanroom.new(fetch(root_class).new, self)
    cleanroom.evaluate dsl

  end

  def fetch_cleanroom(root_class)
    BaseCleanroom.new(fetch(root_class).new, self)
  end

  def create_cleanroom(root_class)
    BaseCleanroom.new(root_class.new, self)
  end

  def marshal_dump
    @classes.inject({}) do |hash, (name, clazz)|
      hash[name] = {xml_name: clazz.tag_name }
      hash[name][:attrs] = clazz.roxml_attrs.map do |accessor|
        type = accessor.sought_type.class == Class ?
          accessor.sought_type.class_name : accessor.sought_type
        from = accessor.sought_type == :attr ? "@#{accessor.name}" : accessor.name
        {
          name: accessor.accessor,
          opts: {
            as: accessor.array? ? [type] : type,
            from: from
          }
        }
      end
      hash
    end
  end

  def classes_to_tree(clazzes, tree = Tree::TreeNode.new(:Root, nil))
    clazzes.each do |name, clazz|
      child_names, serialized_class = serialized_class clazz
      child = tree.add(name, serialized_class)
      classes_to_tree child_names, child
    end

  end

  def serialize_class(clazz)
    []
  end

  def marshal_load data
    @classes = data.inject({}) do |hash, (name, opts)|
      clazz = new_roxml_class opts[:name]
      opts[:attrs].each do |attr|
        clazz.xml_accessor attr[:name], attr[:opts]
      end
      hash[name] = clazz
    end
  end

  def serialize(path)
    file = File.new path, 'w'
    Marshal.dump self, file
    file.close
  end

  def self.load(path)
    file = File.open path, 'r'
    Marshal.load file
  end
end