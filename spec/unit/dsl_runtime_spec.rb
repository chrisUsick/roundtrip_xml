require './spec/spec_helper'
require 'set'

describe 'dsl_runtime' do
  it 'it adds properties found across multiple documents' do
    docs = [fixture_path('match-rule-01.xml'), fixture_path('match-rule-02.xml')]
    runtime = DslRuntime.new
    runtime.populate(docs)
    match_rule_class = runtime.fetch :MatchRule
    attrs = match_rule_class.roxml_attrs
    expect(attrs.size).to eq(2)
    expect(attrs[0].sought_type).to eq(runtime.fetch :NormalRule)
    expect(attrs[1].sought_type).to eq(runtime.fetch :PojoRule)

  end

  it 'serializes and deserializes' do
    docs = [fixture_path('match-rule-01.xml'), fixture_path('healthrules02.xml')]
    runtime = DslRuntime.new
    runtime.populate(docs)
    def get_names (classes)
      classes.keys
    end
    classes = get_names runtime.instance_variable_get(:@classes)
    dump_path = fixture_path 'dsl_runtime_dump'
    runtime.serialize(dump_path)
    new_runtime = DslRuntime.load dump_path
    new_classes = get_names new_runtime.instance_variable_get(:@classes)
    expect(new_classes).to include(*classes)
  end

  it 'marshal_dumps' do
    docs = [fixture_path('match-rule-01.xml'), fixture_path('match-rule-02.xml')]
    runtime = DslRuntime.new
    runtime.populate(docs)
    def get_names (classes)
      Set.new classes.keys
    end
    classes = get_names runtime.instance_variable_get(:@classes)
    dump_path = fixture_path 'dsl_runtime_dump'
    data = runtime.marshal_dump
    expect(data[:root_classes]).to include(:MatchRule)
    expect(data[:root_classes].length).to eq(1)
    expect(data[:classes]).to be_truthy
  end

  it 'marshal_loads' do
    docs = [fixture_path('match-rule-01.xml')]
    runtime = DslRuntime.new
    runtime.populate(docs)
    def get_names (classes)
      Set.new classes.keys
    end
    old_classes = get_names runtime.instance_variable_get(:@classes)
    data = runtime.marshal_dump
    runtime.marshal_load data
    new_classes = get_names runtime.instance_variable_get(:@classes)
    expect(new_classes).to eq(old_classes)

  end

  describe 'child_classes' do
    it 'extracts child classes' do
      hash = {
        A: 1,
        B: 2
      }
      config = {
        attrs: [
          {
            opts: {as: :A}
          },
          {
            opts: {as: :B}
          }
        ]

      }

      runtime = DslRuntime.new
      children = runtime.child_classes hash, config
      expect(children).to include(:A, :B)
    end
  end

  describe 'recursive structures' do
    let :xml do
      <<-XML
<a>
  <b>
    <b>
      <e>quux</e>
    </b>
    <a>
      <b>
        <e>foo</e>
      </b>
    </a>
    <e>bar</e>
  </b>
  <c>
    <d>
      <b>
        <a>
          <b>
            <e>foo2</e>
          </b>
        </a>
        <e>bar2</e>
      </b>
    </d>
  </c>
</a>
      XML
    end

    let :dump_data do
      runtime = DslRuntime.new
      runtime.populate_raw xml
      runtime.marshal_dump
    end

    it 'serializes recursive structure' do
      expect(dump_data).to be_truthy
    end

    it 'deserializes' do
      def expect_attrs(clazz, hash)
        attrs = clazz.roxml_attrs.map {|a| {accessor: a.accessor, type: a.sought_type}}

        expected_attrs = hash.inject([]) {|out, (name, value)| out << {accessor: name.to_s, type: value}}
        expect(attrs).to include(*expected_attrs)
        expect(attrs.size).to eq(expected_attrs.size)
      end
      runtime = DslRuntime.new
      runtime.marshal_load dump_data
      classes = runtime.instance_variable_get :@classes
      a_class = classes[:A]
      b_class = classes[:B]
      c_class = classes[:C]
      d_class = classes[:D]
      expect_attrs(a_class, b: b_class, c: c_class)
      expect_attrs(b_class, a: a_class, b: b_class, e: :text)
      expect_attrs(c_class, d: d_class)
      expect_attrs(d_class, b: b_class)


    end
  end

  it 'writes refactored code' do
    doc = fixture('refactorable-dsl.xml')
    templates = fixture('healthrule-helpers.rb')
    runtime = DslRuntime.new
    runtime.populate_raw doc
    actual = runtime.write_dsl doc, :HealthRules, :healthRule, [templates]

    expect(actual.scan(/policyCondition :PolicyCondition2/).size).to eq 4
    expect(actual.scan(/warningExecutionCriteria :RegularExecutionCriteria/).size).to eq 7
    expect(actual.scan(/metricExpression :BasicExpression do/).size).to eq 20

  end
  it 'writes unrefactored code when no helpers are given' do
    doc = fixture('refactorable-dsl.xml')
    runtime = DslRuntime.new
    runtime.populate_raw doc
    actual = runtime.write_dsl doc, :HealthRules, :healthRule

    expect(actual.scan(/healthRule do/).size).to eq 7
  end

  it 'partitions dsl if a partitioning block is given' do
    doc = fixture('refactorable-dsl.xml')
    runtime = DslRuntime.new
    runtime.populate_raw doc
    actual = runtime.write_dsl doc, :HealthRules, :healthRule do |rule|
      rule.criticalExecutionCriteria.policyCondition.type == 'leaf' ? 'simple' : 'complex'
    end
    expect(actual['simple'].scan(/healthRule do/).size).to eq 5
    expect(actual['complex'].scan(/healthRule do/).size).to eq 2

  end

  context 'lifecycle callbacks' do
    let(:runtime) {DslRuntime.new}
    it 'calls `after_roxml_created` callback' do
      allow(runtime).to receive(:trigger)
      doc = fixture('refactorable-dsl.xml')
      runtime.populate_raw doc
      runtime.on :after_roxml_created do |roxml|
        expect(roxml).to kind_of ROXML
      end
      runtime.write_dsl doc, :HealthRules, :healthRule
      expect(runtime).to have_received(:trigger).with(:after_roxml_created, kind_of(ROXML))
    end
  end
end