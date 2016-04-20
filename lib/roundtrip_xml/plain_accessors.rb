module PlainAccessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def plain_accessor(name, default = nil)
      @plain_accessors ||= {}
      @plain_accessors[name] = default
      attr_writer name
      define_method(name) do
        instance_variable_get "@#{name}" || @plain_accessors[name]
      end
    end

    def plain_accessors(hash = false)
      return @plain_accessors || {} if hash
      (@plain_accessors && @plain_accessors.keys) || []
    end
  end
end