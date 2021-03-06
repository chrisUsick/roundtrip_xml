require './spec/spec_helper'

describe 'SexpDslBuilder' do
  it 'does stuff' do
    s = SexpDslBuilder.new nil, nil
    # pp s.exp.to_a
    # s.demo

  end

  it 'writes a simple roxml object' do
    runtime = DslRuntime.new
    clazz = runtime.new_roxml_class 'Foo'
    clazz.xml_accessor :a_attr
    clazz.xml_accessor :b_attr
    clazz.xml_accessor :c_attr
    clazz.xml_accessor :d_attr
    obj = clazz.new
    obj.a_attr = "a's"
    obj.b_attr = 'bb'
    obj.c_attr = 'c - c'
    obj.d_attr = 'd (d)'

    builder = SexpDslBuilder.new obj, runtime
    actual = builder.write_roxml_obj obj

    expected = <<EXP
a_attr "a's"
b_attr 'bb'
c_attr 'c - c'
d_attr 'd (d)'
EXP
    expect(actual.gsub(' ', '').strip).to eq(expected.gsub(' ', '').strip)

  end

  it 'writes a nested roxml object' do
    runtime = DslRuntime.new
    foo_class = runtime.new_roxml_class 'Foo'
    b_class = runtime.new_roxml_class 'B'
    c_class = runtime.new_roxml_class 'C'

    foo_class.xml_accessor :a
    foo_class.xml_accessor :b, as: b_class
    foo_class.xml_accessor :c, as: c_class
    b_class.xml_accessor :d
    b_class.xml_accessor :e
    c_class.xml_accessor :f
    obj = foo_class.new
    obj.a = 'a'
    obj.c = c_class.new
    obj.c.f = 'f'
    obj.b = b_class.new
    obj.b.d = 'd'
    obj.b.e = 'e'

    builder = SexpDslBuilder.new obj, runtime
    actual = builder.write_roxml_obj obj

    expected = <<EXP
a 'a'
b do
  d 'd'
  e 'e'
end
c { f 'f'}
EXP
    expect(actual.gsub(' ', '').strip).to eq(expected.gsub(' ', '').strip)
  end

  it 'builds complex dsl' do
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    el = res.get_el
    templates = fixture('healthrule-helpers.rb')
    extractor = Extractor.new el, runtime, :HealthRules, [templates]

    new_el = extractor.convert_roxml_obj el

    builder = SexpDslBuilder.new new_el, runtime

    actual = builder.write_roxml_obj new_el

    # puts actual

    expect(actual.scan(/policyCondition :PolicyCondition2/).size).to eq 4
    expect(actual.scan(/warningExecutionCriteria :RegularExecutionCriteria/).size).to eq 7
    expect(actual.scan(/metricExpression :BasicExpression do/).size).to eq 20
  end

  it 'can parse nested multiple children' do
      runtime = DslRuntime.new
      xml = fixture('array-elements.xml')
      runtime.populate_raw xml
      roxml_root = runtime.fetch(:HealthRules).from_xml xml
      healthrule = roxml_root.healthRule
      roxml_root.healthRule = [healthrule]

      extractor = Extractor.new roxml_root.healthRule, runtime, :HealthRules
      new_objs = extractor.convert_roxml_objs


      builder = SexpDslBuilder.new roxml_root, runtime

      dsl = builder.write_full_dsl :healthRule
      names = ['atv','config','cookie','cus','emp','epsilon','geosvc','payments','push-api','push-trigger','shieldgsisingester','shieldprx','sso','subman','thor','userman','videourl','vts','vzauth']

      names.each do |name|
        expect(dsl).to include "applicationComponent '#{name}'"
      end

  end

  it 'gets the metadata' do
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    dsl = <<-RUBY
healthRule do
  _metadata foo: 'bar'
  name 'health rule 1'
end
    RUBY
    res = runtime.evaluate_raw dsl, :HealthRules
    el = res.get_el
    templates = fixture('healthrule-helpers.rb')
    extractor = Extractor.new el, runtime, :HealthRules, [templates]

    new_el = extractor.convert_roxml_obj el

    builder = SexpDslBuilder.new new_el, runtime

    actual = builder.write_roxml_obj new_el

    expect(actual).to match("_metadata :foo => 'bar'")
    expect(actual).to match("name 'health rule 1'")
  end

end