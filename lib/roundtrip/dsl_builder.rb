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
      accessor = attr.accessor
      selector = attr.name

      if attr.sought_type == :text
        out += inset + "#{accessor} '#{xml.xpath(selector)[0].content}'\n"
      elsif attr.sought_type == :attr
        out += inset + "#{accessor} '#{xml.xpath("@#{selector}")[0].content}'\n"
      elsif !attr.array?
        out += inset + "#{accessor} do\n#{write_attrs attr.sought_type, xml.xpath(selector)[0], inset + '  '}#{inset}end\n"

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