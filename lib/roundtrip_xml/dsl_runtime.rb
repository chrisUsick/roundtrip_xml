require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/roxml_builder'
require 'roundtrip_xml/root_cleanroom'
require 'roundtrip_xml/base_cleanroom'
# Class which evaluates DSL and read XML files to populate the namespace with classes
class DslRuntime
  def initialize()
    @classes = {}
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
end