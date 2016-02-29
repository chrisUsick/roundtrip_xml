require './spec/spec_helper'

describe 'building DSL from simple XML and recreating the sample' do
  it 'is the same' do
    runtime = DslRuntime.new
    runtime.populate_raw(fixture('simple-children.xml'))
    actual = runtime.evaluate_file(fixture_path('simple-children.rb'), :A).get_el.to_xml
    children = actual.children
    expect(children[0].name).to eq('b')
    expect(children[0].content).to match(/foo/)
    expect(children[1].name).to eq('c')
    expect(children[1].content).to match(/bar/)

    # expect(actual.to_xml.children.size).to be > 0
  end
end
