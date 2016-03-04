require 'roxml'
require 'nokogiri'
require './lib/roxml_builder'
require './lib/base_cleanroom'
require './lib/root_cleanroom'
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

  def evaluate_file(path, root_class)
    cleanroom = RootCleanroom.new(fetch(root_class).new, self)
    cleanroom.evaluate_file path

  end

  def fetch_cleanroom(root_class)
    BaseCleanroom.new(fetch(root_class).new, self)
  end
end