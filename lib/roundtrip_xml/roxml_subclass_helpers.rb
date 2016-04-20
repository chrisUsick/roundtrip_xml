module RoxmlSubclassHelpers
  def self.included(base)
    base.extend ClassMethods
  end
  module ClassMethods
    attr_writer :defaults
    def defaults
      @defaults || {}
    end
  end
end