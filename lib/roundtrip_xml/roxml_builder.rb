# require 'roxml'
require 'nokogiri'
require 'roundtrip_xml/plain_accessors'
# Builds dynamic classes based on an XML file.
# Classes that already exist in the DslRuntime instance are modified if necessary, not overridden.
class RoxmlBuilder
  def initialize (root, current_classes = {})
    # @type Nokogiri::Element
    @root = root

    # @type Map<Symbol, ROXML>
    @generated_classes = current_classes

    @root_class = @generated_classes[name_to_sym(root.name)] || Class.new do
      include ROXML
      include PlainAccessors
      xml_convention :dasherize
      xml_name root.name
      def attributes
        self.class.roxml_attrs
      end
    end

    @generated_classes[ name_to_sym(@root.name)] = @root_class
    @nodes = {}
  end
  def build_classes
    # @root_class.xml_name (@root.name)
    @root.xpath("//#{@root.name}/*|//#{@root.name}/@*").each do |child|
      default_opts = {from:child.name}
      if is_leaf_element?(child)
        add_accessor name_to_sym(child.name, true), default_opts, @root
      elsif child.type == Nokogiri::XML::Node::ATTRIBUTE_NODE
        add_accessor name_to_sym(child.name, true), {from: "@#{child.name}"}, @root
      else
        builder = RoxmlBuilder.new child, @generated_classes
        new_classes = builder.build_classes
        child_name = name_to_sym(child.name, true)
        child_class_name = name_to_sym child.name
        add_accessor child_name, default_opts.merge({as: new_classes[child_class_name]}), @root
        @generated_classes.merge!(new_classes)
      end
    end

    @generated_classes
  end

  def name_to_sym(name, lower_case = false)
    # name.gsub('-', '_').to_sym
    new_name = name.split('-').collect(&:capitalize).join
    new_name[0] = new_name[0].downcase! if lower_case
    new_name.to_sym
  end


  def add_accessor(name, opts = {}, node)
    attrs = @root_class.roxml_attrs
    attr = attrs.find do |a|
      a.accessor.to_sym == name
    end
    # if class already has xml attribute, delete the old version and add the new version

    if attr
      if node_has_child?(node, attr.name)
        @root_class.instance_variable_set(:@roxml_attrs, attrs.select {|i| i != attr })
        new_attr_type = opts[:as]
        # add a new attribute with the array type.
        @root_class.xml_accessor name, opts.merge({as: [new_attr_type]})
      end
    else
      @root_class.xml_accessor name, opts
      add_child_to_node(node, attr.name)
    end
  end

  # element is a leaf it has text content and no attributes
  def is_leaf_element?(element)
    element.type == Nokogiri::XML::Node::ELEMENT_NODE &&
      element.attributes.size == 0 &&
      element.children.select {|c| c.type == Nokogiri::XML::Node::ELEMENT_NODE}.empty?
  end

  def node_has_child?(node, child)
    @nodes[node.pointer_id][child]
  end

  def add_child_to_node(node, child)
    @nodes[node.pointer_id] ||= {}
    @nodes[node.pointer_id][child] = true
  end
end