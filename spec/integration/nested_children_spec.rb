require './spec/spec_helper'

describe 'building DSL from XML and recreating the sample' do
  it 'is the same' do
    expected = Nokogiri::XML(fixture('nested-children.xml')).root
    runtime = DslRuntime.new
    runtime.populate_raw(fixture('nested-children.xml'))
    actual = runtime.evaluate_file(fixture_path('nested-children.rb'), :A).get_el
    # expected.diff(actual) do |change, node|
    #   puts "#{change} #{node.to_xml}".ljust(30) #+ node.parent.path
    #   # expect(change).to be('')
    # end
    children = actual.to_xml.children
    expect(children.size).to be == 1
    expect(children[0].css('e')[0].content).to match(/baz/)

  end
end