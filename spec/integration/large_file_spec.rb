require './spec/spec_helper'
require './spec/fixtures'

describe 'preparing a large file' do
  let(:runtime) { DslRuntime.new }
  let(:xml_str) { fixture('large_td.xml') }

  it 'populates the runtime' do
    runtime.populate_raw xml_str
    expect(runtime.fetch(:CustomMatchPoint)).to be_kind_of Class
  end

  it 'builds the DSL' do
    runtime.populate_raw xml_str
    builder = DslBuilder.new(xml_str, runtime, :CustomMatchPoints)
    dsl = builder.to_dsl
    puts dsl
    expect(dsl).to be_truthy

  end

end