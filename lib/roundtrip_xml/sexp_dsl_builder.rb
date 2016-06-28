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

  attr_accessor :roxml_objs, :runtime
  def initialize(roxml_obj, runtime)
    @roxml_obj = roxml_obj
    self.runtime = runtime
  end

  def create_sexp_for_roxml_obj(obj, root_method = nil)
    is_subclass = obj.class.subclass?
    subclass_value = is_subclass ? [:lit, obj.class.class_name] : nil
    accessors = []
    obj.attributes.each do |attr|
      val = obj.send attr.accessor
      next unless val

      if attr.sought_type.class == Symbol
        if val.is_a? Array
          val.each {|v| accessors << [:call, nil, attr.accessor, [:str, v]]}
        else
          accessors << [:call, nil, attr.accessor, [:str, val]]
        end
      elsif val.class == Array
        val.each { |v| accessors << create_sexp_for_roxml_obj(v, attr.accessor) }
      else
        accessors << create_sexp_for_roxml_obj(val, attr.accessor) if val
      end
    end.compact
    # plain accessors
    obj.class.plain_accessors.each do |a|
      val = obj.send a
      next unless val
      accessors << [:call, nil, a, [:str, val]]
    end
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

  def write_roxml_obj(obj)
    s = create_sexp_for_roxml_obj obj

    sexp = Sexp.from_array s
    processor = Ruby2Ruby.new
    str = processor.process(sexp)
    str.gsub(/([^"])\(([^\(\)]*|".*")\)([^"])([^{]|$)/, '\\1 \\2\\3\\4').gsub(/"([^'\n]+)"/, "'\\1'")
  end

  def write_full_dsl(root_method)
    write_roxml_obj @roxml_obj
  end

end
