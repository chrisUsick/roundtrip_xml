require 'roundtrip_xml/utils'
module PlainAccessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def plain_accessor(name, matcher = /(\S*)/)
      @plain_accessors ||= {}
      @plain_accessors[name] = matcher
      attr_writer name
      define_method(name) do
        val = instance_variable_get "@#{name}"
        val
        # @plain_accessors is actually nil here
        # val.nil? ? @plain_accessors[name] : val
      end
    end

    def plain_accessors(hash = false)
      return @plain_accessors || {} if hash
      (@plain_accessors && @plain_accessors.keys) || []
    end
  end
end