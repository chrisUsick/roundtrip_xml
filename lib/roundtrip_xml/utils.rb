require 'roxml'
require 'roundtrip_xml/plain_accessors'
require 'set'
def name_to_sym_helper(name, lower_case = false)
  new_name = name.split('-').collect(&:capitalize).join
    new_name[0] = new_name[0].downcase! if lower_case
    new_name.to_sym
end
module Utils
  UNDEFINED_PARAM = 'UNDEFINED_PARAM'.freeze
  class UndefinedParam
    attr_reader :name, :original
    def initialize(name, original = nil)
      @name = name
      @original = original
    end

    def to_s
      "#{Utils::UNDEFINED_PARAM}:#{@name}"
    end
  end

  VAR_SUFIX = '_v'.freeze
  def self.included(base)
    unless base.const_defined?(:VAR_SUFIX)
      base.const_set :VAR_SUFIX, Utils::VAR_SUFIX
    end
  end
  def new_roxml_class(name, parent = Object, &block)
    Class.new(parent) do
      include ROXML
      include PlainAccessors
      attr_writer :_metadata
      def _metadata
        @_metadata || {}
      end
      xml_convention :dasherize
      xml_name parent.respond_to?(:tag_name) ? parent.tag_name : name

      # by default a ROXML class isn't a sub class
      def self.subclass?
        @is_subclass || false
      end
      def attributes
        self.class.roxml_attrs
      end

      def self.class_name
        @class_name || name_to_sym_helper(self.tag_name)
      end

      def to_hash
        attributes.inject({}) do |hash, a|
          value = a.to_ref(self).to_xml(self)
          value = value.to_hash if value.respond_to? :to_hash

          hash[a.accessor] = value
          hash['__class'] = self.class.class_name
          hash
        end
      end

      def self.from_hash(runtime, hash)
        hash.delete '__class'
        obj = self.new
        hash.each do |k, val|
          if val.is_a? Hash
            val = runtime.fetch(val['__class']).from_hash(runtime, val)
          end
          obj.send "#{k}=", val
        end
        obj
      end
      def self.unique_parent_accessors
        plain = Set.new(plain_accessors.map {|accessor| accessor.to_s.gsub(VAR_SUFIX, '').to_sym})
        parent_accessors = Set.new(roxml_attrs.map { |attr| attr.accessor })
        parent_accessors - plain
      end
      class_eval &block if block_given?
    end

  end

  def name_to_sym(name, lower_case = false)
    name_to_sym_helper(name, lower_case)
  end
end