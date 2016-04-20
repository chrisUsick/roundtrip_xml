require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/roxml_builder'
require 'roundtrip_xml/root_cleanroom'
require 'roundtrip_xml/base_cleanroom'
require 'roundtrip_xml/utils'
require 'roundtrip_xml/sexp_dsl_builder'
require 'tree'
require 'set'
# Class which evaluates DSL and read XML files to populate the namespace with classes
class DslRuntime
  include Utils
  def initialize()
    @classes = {}
    @root_classes = Set.new
  end
  def populate(files, root_method=nil)
    files.map {|f| populate_from_file f, root_method }
  end

  def populate_from_file (file, root_method=nil)
    populate_raw File.read(file), root_method

  end

  def populate_raw (raw, root_method = nil)
    builder = RoxmlBuilder.new (Nokogiri::XML(raw).root), @classes
    new_classes = builder.build_classes
    @root_classes << builder.root_class_name
    @classes.merge! new_classes
    if root_method
      roxml_root = fetch(builder.root_class_name).from_xml raw

      extractor = Extractor.new roxml_root.send(root_method), self

      new_objs = extractor.convert_roxml_objs
      subclasses = extractor.subclasses
      roxml_root.send("#{root_method}=", new_objs)
      builder = SexpDslBuilder.new [roxml_root], subclasses, self

      builder.write_roxml_objs
    end
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
    classes = @classes.inject({}) do |hash, (name, clazz)|
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

    {
      root_classes: @root_classes,
      classes: classes
    }
  end

  def deserialize_class(node, config)
    clazz = fetch(node.name) || new_roxml_class(config[:xml_name])
    config[:attrs].each do |attr|
      type_is_parent = node.parentage && node.parentage.any? {|n| n.name == attr[:opts][:as]}
      if type_is_parent
        add_unprocessed_attr attr, clazz
      else
        clazz.xml_accessor attr[:name], transform_accessor_opts(attr[:opts])
      end
    end
    clazz
  end

  def add_unprocessed_attr(attr_config, clazz)
    @unprocessed_attrs ||= []
    @unprocessed_attrs << AttrJob.new(attr_config, clazz)
  end

  def transform_accessor_opts(opts)
    attr_type = opts[:as]
    is_array = attr_type.class == Array
    type = is_array ? attr_type.first : attr_type
    if is_array
      opts[:as] = [fetch(type)]
    else
      opts[:as] = fetch type
    end
    opts
  end

  def marshal_load(data)
    initialize
    @root_classes.merge data[:root_classes]
    trees = @root_classes.map {|clazz| hash_to_tree data[:classes], clazz}
    trees.each do |tree|
      tree.postordered_each do |node|
        @classes[node.name] = deserialize_class(node, node.content)
      end
    end
    @unprocessed_attrs.each do |job|
      clazz = job.class
      config = job.config
      clazz.xml_accessor config[:name], transform_accessor_opts(config[:opts])
    end if @unprocessed_attrs
  end

  def hash_to_tree(hash, root_name, processed = [])
    node = Tree::TreeNode.new(root_name, hash[root_name])
    processed << root_name
    children = child_classes(hash, hash[root_name])
    children.each do |name|
      node << hash_to_tree(hash, name, processed) unless processed.include? name
    end
    node
  end

  def child_classes(hash, config)
    config[:attrs].map do |attr|
      attr_type = attr[:opts][:as]
      type = attr_type.class == Array ? attr_type.first : attr_type
      type if hash.key? type
    end.compact
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

class AttrJob
  attr_accessor :class, :config
  def initialize(config, clazz)
    self.config = config
    self.class = clazz
  end
end