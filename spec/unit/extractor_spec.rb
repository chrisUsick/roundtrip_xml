require './spec/spec_helper'
require 'pp'

describe 'extractor' do
  it 'compares' do
    # get some ROXML classes
    runtime = DslRuntime.new
    runtime.populate_from_file fixture_path('refactorable-dsl.xml')
    res = runtime.evaluate_file fixture_path('refactorable-dsl.rb'), :HealthRules
    extractor = Extractor.new res.get_el.healthRule, runtime

    fields = extractor.similar_fields
    extractor.create_romxl_class fields, :HealthRules
    pp fields
  end
end