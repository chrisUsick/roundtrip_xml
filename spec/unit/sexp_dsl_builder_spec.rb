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
    clazz.xml_accessor :a
    clazz.xml_accessor :b
    clazz.xml_accessor :c
    obj = clazz.new
    obj.a = 'a'
    obj.b = 'b'
    obj.c = 'c'

    builder = SexpDslBuilder.new obj, runtime
    actual = builder.write_roxml_obj obj

    expected = <<EXP
a 'a'
b 'b'
c 'c'
EXP
    expect(actual.gsub(' ', '').strip).to eq(expected.gsub(' ', '').strip)

  end

  it 'writes a nested roxml object' do
    runtime = DslRuntime.new
    foo_class = runtime.new_roxml_class 'Foo'
    b_class = runtime.new_roxml_class 'B'

    foo_class.xml_accessor :a
    foo_class.xml_accessor :b, as: b_class
    foo_class.xml_accessor :c
    b_class.xml_accessor :d
    b_class.xml_accessor :e
    obj = foo_class.new
    obj.a = 'a'
    obj.c = 'c'
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
c 'c'
EXP
    expect(actual.gsub(' ', '').strip).to eq(expected.gsub(' ', '').strip)
  end

  it 'builds complex dsl' do
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    el = res.get_el
    templates = fixture('healthrule-helpers.rb')
    extractor = Extractor.new el, runtime, :HealthRules, templates

    new_el = extractor.convert_roxml_obj el

    builder = SexpDslBuilder.new new_el, runtime

    actual = builder.write_roxml_obj new_el

    # puts actual

    expect(actual.scan(/policyCondition :PolicyCondition2/).size).to eq 4
    expect(actual.scan(/warningExecutionCriteria :RegularExecutionCriteria/).size).to eq 7
    expect(actual.scan(/metricExpression :BasicExpression  do/).size).to eq 20
  end


end