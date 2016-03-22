require 'nokogiri'

class DslBuilder
  def initialize(xmlStr, runtime, root_class)
    @doc = Nokogiri::XML(xmlStr)
    @runtime = runtime
    @root_class = root_class
  end

  def to_dsl
    write_attrs @runtime.fetch(@root_class), @doc.root
  end

  def write_attrs(clazz, xml, inset='')
    clazz.roxml_attrs.inject('') do |out, attr|
      # if no xml was found for the given selector, the attribute was optional
      return '' unless xml
      accessor = attr.accessor
      selector = attr.name

      if attr.sought_type == :text
        text_element = xml.children.find {|c| c.name == selector}
        out += inset + "#{accessor} '#{text_element.content}'\n" if text_element
      elsif attr.sought_type == :attr
        child_attribute = xml.attributes[selector]
        out += inset + "#{accessor} '#{child_attribute.content}'\n" if child_attribute
      elsif !attr.array?
        # the element that matches `selector` may not be in this node
        child_element = xml.children.find {|c| c.name == selector}
        if child_element
          out += inset + "#{accessor} do\n#{write_attrs attr.sought_type, child_element, inset + '  '}#{inset}end\n"
        end
      else
        xml.xpath(selector).each do |node|
          out += inset + "#{accessor} do\n#{write_attrs attr.sought_type, node, inset + '  '}#{inset}end\n"
          if inset == ''
            out += "\n"
          end
        end
      end

      out
    end
  end
end
