require './spec/spec_helper'

describe 'RoxmlBuilder' do

  it 'builds an element with only leaf children' do
    xml = '<a><b>foo</b></a>'
    builder = RoxmlBuilder.new(Nokogiri::XML(xml).root)
    new_classes = builder.build_classes
    expect(new_classes.length).to be(1)
    expect(new_classes).to include(:A)
    expect(new_classes[:A].new.attributes[0].name).to eq('b')
  end

  it 'makes an element be of type array' do
    xml = '<a><b>foo</b> <b>bar</b></a>'
    builder = RoxmlBuilder.new(Nokogiri::XML(xml).root)
    new_classes = builder.build_classes
    el = new_classes[0].new
    b_attribute = el.attributes[0]
    expect(b_attribute.array?).to be_truthy
  end


  it 'foo' do
    class Quux
      include ROXML
      # xml_accessor :element
      xml_accessor :quux
    end
    class RoxmlTest
      include ROXML
      xml_name 'roxml-test'
      xml_accessor :foo
      xml_accessor :quuxes, from: 'quux'
      # xml_accessor :quux, as: {value: 'quux' }
    end

    xml = '<roxml-test><foo>1</foo><quuxes><quux>2</quux><quux>3</quux></quuxes></roxml-test>'
    t = RoxmlTest.from_xml(xml)
    expect(t).to be_truthy

  end
end