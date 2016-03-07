require './spec/spec_helper'

describe 'root_cleanroom' do
  it 'adds a definition to the runtime' do
    xml = <<-XML
<a><b>1</b><c><d>2</d></c></a>
    XML
    dsl = <<-DSL
define :CSub, :C, :d_val do
  d d_val + 1
end
b 1
c :CSub do
  d_val 1
end
    DSL

    runtime = DslRuntime.new
    runtime.populate_raw(xml)
    # modify class to have non xmla accessor attribute
    el = runtime.evaluate_raw(dsl, :A).get_el
    expect(el.c.d).to eq 2
  end

  it 'handles deeply nested elements' do
    xml = <<-XML
<a><b>1</b><c>
<d><e>2</e><f><g>3</g></f></d></c></a>
    XML

    runtime = DslRuntime.new
    runtime.populate_raw(xml)
    # modify class to have non xmla accessor attribute
    a_class = runtime.fetch(:A)
    el = runtime.evaluate_file(fixture_path('dsl_definitions.rb'), :A).get_el
    expect(el.c.d.e).to eq 2
    expect(el.c.d.f.g).to eq 3
  end
end
