require './spec/spec_helper'

describe 'SexpDslBuilder' do
  it 'does stuff' do
    s = SexpDslBuilder.new nil, nil, nil
    pp s.exp.to_a
    # s.demo

  end

  it 'writes subclasses' do
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    extractor = Extractor.new res.get_el.healthRule, runtime

    new_objs = extractor.convert_roxml_objs
    subclassess = extractor.subclasses

    builder = SexpDslBuilder.new new_objs, subclassess, runtime

    actual = builder.write_def_classes

    expected = <<EXP
define(:Healthrule1, :HealthRule) do
  enabled("true")
  isDefault("true")
  alwaysEnabled("true")
  durationMin("30")
  waitTimeMin("30")
end
EXP
    expect(actual).to eq(expected.strip)

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

    builder = SexpDslBuilder.new [obj], [], runtime
    actual = builder.write_roxml_obj obj, :foo

    expected = <<EXP
foo do
  a("a")
  b("b")
  c("c")
end
EXP
    expect(actual).to eq(expected.strip)

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

    builder = SexpDslBuilder.new [obj], [], runtime
    actual = builder.write_roxml_obj obj, :foo

    expected = <<EXP
foo do
  a("a")
  b do
    d("d")
    e("e")
  end
  c("c")
end
EXP
    expect(actual).to eq(expected.strip)
  end

  it 'builds complex dsl' do
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    extractor = Extractor.new res.get_el.healthRule, runtime

    new_objs = extractor.convert_roxml_objs
    subclassess = extractor.subclasses

    builder = SexpDslBuilder.new new_objs, subclassess, runtime

    actual = builder.write_roxml_obj new_objs[0], :healthrule

    # puts actual
    expected = fixture('simple-auto-refactor.rb')
    expect(actual).to eq(expected)
  end

  it 'refactors all objects' do
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    extractor = Extractor.new res.get_el.healthRule, runtime

    new_objs = extractor.convert_roxml_objs
    subclassess = extractor.subclasses

    builder = SexpDslBuilder.new new_objs, subclassess, runtime

    actual = builder.write_roxml_objs :healthrule

    # puts actual
    expected = fixture('full-simple-refactor.rb')
    expect(actual.strip).to eq(expected.strip)
  end

  it 'handles an array property' do
    runtime = DslRuntime.new
    raw = fixture('refactorable-dsl-small.xml')
    runtime.populate_raw raw
    roxml_root = runtime.fetch(:HealthRules).from_xml raw
    root_method = :healthRule
    extractor = Extractor.new roxml_root.send(root_method), runtime

    new_objs = extractor.convert_roxml_objs
    subclasses = extractor.subclasses
    roxml_root.send("#{root_method}=", new_objs)
    builder = SexpDslBuilder.new [roxml_root], subclasses, runtime

    actual = builder.write_roxml_objs
    expected = fixture('refactorable-dsl-small.rb')
    expect(actual.strip).to eq(expected.strip)
  end

end