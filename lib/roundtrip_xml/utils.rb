require 'roxml'
require 'roundtrip_xml/plain_accessors'
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
    end
  end
end