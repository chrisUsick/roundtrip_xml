require './spec/spec_helper'

describe 'tranforming dsl which uses an external file of helpers to xml' do
  it 'works' do
    xml = fixture('healthrules01.xml')
    runtime = DslRuntime.new
    runtime.populate_raw xml

    actual = runtime.evaluate_file(fixture_path('healthrules-dsl.rb'), :HealthRules).get_el.to_xml
    expect(actual.to_s).to eq xml
  end
end
