require 'roxml'
require 'roundtrip_xml/plain_accessors'
def name_to_sym_helper(name, lower_case = false)
  new_name = name.split('-').collect(&:capitalize).join
    new_name[0] = new_name[0].downcase! if lower_case
    new_name.to_sym
end
module Utils
  def new_roxml_class name
    Class.new do
      include ROXML
      include PlainAccessors
      xml_convention :dasherize
      xml_name name
      def attributes
        self.class.roxml_attrs
      end

      def self.class_name
        name_to_sym_helper self.tag_name
      end
    end
  end

  def name_to_sym(name, lower_case = false)
    name_to_sym_helper(name, lower_case)
  end
end