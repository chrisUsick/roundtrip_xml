require './spec/spec_helper'

describe 'tranforming a healthrules xml file to dsl and evaluating the dsl' do
  it 'works' do
    xml = fixture('healthrules01.xml')
    runtime = DslRuntime.new
    runtime.populate_raw xml
    b = DslBuilder.new xml, runtime, :HealthRules
    out = b.to_dsl
    actual = runtime.evaluate_raw(out, :HealthRules).get_el.to_xml

    expect(actual.to_s).to eq xml
  end
end
