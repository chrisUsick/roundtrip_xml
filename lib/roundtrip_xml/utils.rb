require 'roxml'
require 'roundtrip_xml/plain_accessors'
def name_to_sym_helper(name, lower_case = false)
  new_name = name.split('-').collect(&:capitalize).join
    new_name[0] = new_name[0].downcase! if lower_case
    new_name.to_sym
end
module Utils
  def new_roxml_class(name, parent = Object)
    Class.new(parent) do
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

      def to_hash
        attributes.inject({}) do |hash, a|
          value = a.to_ref(self).to_xml(self)
          value = value.to_hash if value.respond_to? :to_hash

          hash[a.accessor] = value
          hash
        end
      end
    end
  end

  def name_to_sym(name, lower_case = false)
    name_to_sym_helper(name, lower_case)
  end
end