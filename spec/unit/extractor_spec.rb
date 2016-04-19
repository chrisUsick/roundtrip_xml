require './spec/spec_helper'
require 'pp'

describe 'extractor' do
  it 'compares' do
    # get some ROXML classes
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    extractor = Extractor.new res.get_el.healthRule, runtime

    new_objs = extractor.convert_roxml_objs
    pp new_objs
  end
end