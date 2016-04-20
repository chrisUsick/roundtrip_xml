# require 'rubygems'
require 'ruby2ruby'
require 'ruby_parser'
require 'pp'
require 'sexp_processor'

class SexpDslBuilder
  def exp
    rub = <<EOF
bar 'adf'
foo do
  a "a" do
    a1 1
    a2 2
  end
  a "a" do
    a1 3
    a2 4
  end
  b "b"
  c "c"
end
EOF

    # s = Sexp.from_array arr
    # processor = Ruby2Ruby.new
    # processor.process(s)
    parser = RubyParser.new
    s = parser.process(rub)
    s
  end

  attr_accessor :roxml_objs, :subclasses, :runtime
  def initialize(roxml_objs, subclasses, runtime)
    self.roxml_objs = roxml_objs
    self.subclasses = subclasses
    self.runtime = runtime
  end

  def write_def_classes
    arr = []
    subclasses.each do |clazz|
      defaults = clazz.defaults.map do |accessor, default|
        [:call, nil, accessor, [:str, default]]
      end
      arr = [:iter,
             [:call, nil, :define,
              [:lit, clazz.class_name],
              [:lit, clazz.superclass.class_name]
             ], 0, [:block, *defaults]]
    end

    sexp = Sexp.from_array arr
    processor = Ruby2Ruby.new
    processor.process(sexp)
  end

  def create_sexp_for_roxml_obj(obj, root_method = nil)
    is_subclass = obj.class.respond_to?(:defaults)
    subclass_value = obj.class.respond_to?(:defaults) ? [:lit, obj.class.class_name] : nil
    accessors = []
    obj.attributes.each do |attr|
      val = obj.send attr.accessor
      if !val || (is_subclass && obj.class.defaults.keys.include?(attr.accessor))
        next
      end
      if attr.sought_type.class == Symbol
        accessors << [:call, nil, attr.accessor, [:str, val || '']]
      elsif val.class == Array
        val.each { |v| accessors << create_sexp_for_roxml_obj(v, attr.accessor) }
      else
        accessors << create_sexp_for_roxml_obj(val, attr.accessor) if val
      end
    end.compact
    root_call = [:call, nil, root_method]
    root_call << subclass_value if subclass_value
    if root_method
      [:iter, root_call,
       0,
       [:block, *accessors]
      ]
    else
      [:block,
       *accessors]
    end


  end

  def write_roxml_obj(obj, root_method)
    s = create_sexp_for_roxml_obj obj, root_method

    sexp = Sexp.from_array s
    processor = Ruby2Ruby.new
    processor.process(sexp).gsub "\"", "'"
  end

  def write_roxml_objs(root_method = nil)
    roxml_objs.inject('') do |out, obj|
      out += write_roxml_obj obj, root_method
      out += "\n\n"
      out
    end

  end


end
