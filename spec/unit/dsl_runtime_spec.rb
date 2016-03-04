require './spec/spec_helper'

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
end