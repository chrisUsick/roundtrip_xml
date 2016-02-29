require 'roxml'
require 'nokogiri'
class RoxmlBuilder
  def initialize (root)
    # @type Nokogiri::Element
    @root = root

    # @type Map<Symbol, ROXML>
    @generated_classes = {}

    @root_class = Class.new do
      include ROXML
      xml_convention :dasherize
      xml_name root.name
      def attributes
        self.class.roxml_attrs
      end
    end

    @generated_classes[ name_to_sym(@root.name)] = @root_class
  end
  def build_classes
    # @root_class.xml_name (@root.name)
    @root.xpath("//#{@root.name}/*").each do |child|
      if is_leaf?(child)
        add_accessor name_to_sym(child.name, true)
      else
        builder = RoxmlBuilder.new child
        new_classes = builder.build_classes
        child_name = name_to_sym(child.name, true)
        child_class_name = name_to_sym child.name
        add_accessor child_name, as: new_classes[child_class_name]
        @generated_classes.merge!(new_classes)
      end
    end

    @generated_classes
  end

  def name_to_sym(name, lower_case = false)
    # name.gsub('-', '_').to_sym
    new_name = name.split('-').collect(&:capitalize).join
    new_name.downcase! if lower_case
    new_name.to_sym
  end


  def add_accessor(name, opts = {})
    attr = @root_class.roxml_attrs.find {|a| a.name.to_sym == name }
    if attr


    end
    @root_class.xml_accessor name, opts
  end

  def is_leaf?(element)
    element.children.select {|c| c.type == Nokogiri::XML::Node::ELEMENT_NODE}.empty?
  end
end