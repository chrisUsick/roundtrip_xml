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
    docs = [fixture_path('match-rule-01.xml'), fixture_path('match-rule-02.xml')]
    runtime = DslRuntime.new
    runtime.populate(docs)
    def get_names (classes)
      Set.new classes.keys
    end
    classes = get_names runtime.instance_variable_get(:@classes)
    dump_path = fixture_path 'dsl_runtime_dump'
    runtime.serialize(dump_path)
    new_runtime = DslRuntime.load dump_path
    new_classes = get_names runtime.instance_variable_get(:@classes)
    expect(new_classes).to eq classes
  end

  it 'serializes' do
    docs = [fixture_path('match-rule-01.xml'), fixture_path('match-rule-02.xml')]
    runtime = DslRuntime.new
    runtime.populate(docs)
    def get_names (classes)
      Set.new classes.keys
    end
    classes = get_names runtime.instance_variable_get(:@classes)
    dump_path = fixture_path 'dsl_runtime_dump'
    runtime.serialize(dump_path)
  end
end