module PlainAccessors
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def plain_accessor(name)
      @plain_accessors ||= []
      @plain_accessors << name
      attr_accessor name
    end

    def plain_accessors
      @plain_accessors || []
    end
  end
end