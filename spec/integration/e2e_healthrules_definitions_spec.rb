require './spec/spec_helper'

describe 'tranforming dsl which uses an external file of helpers to xml' do
  it 'works' do
    # populates runtime from this xml file
    xml = fixture('healthrules01.xml')
    runtime = DslRuntime.new
    runtime.populate_raw xml

    # evaluates the DSL and verifies that it is a character for character match of the original
    actual = runtime.evaluate_file(fixture_path('healthrules-dsl.rb'), :HealthRules).get_el.to_xml
    expect(actual.to_s).to eq xml
  end
end
