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
    xml = '<a><b><foo>1</foo></b> <b><foo>2</foo></b></a>'
    builder = RoxmlBuilder.new(Nokogiri::XML(xml).root)
    new_classes = builder.build_classes
    el = new_classes[:A].new
    b_attribute = el.attributes.find {|a| a.name == 'b'}
    expect(b_attribute.array?).to be_truthy
  end


  it "doesn't make attr array when encountered in different contexts" do
    xml = <<-XML
<a-container>
<a><b><foo>1</foo></b></a>
<a><b><foo>2</foo></b></a>
</a-container>
    XML
    builder = RoxmlBuilder.new(Nokogiri::XML(xml).root)
    new_classes = builder.build_classes
    b_attribute = new_classes[:A].roxml_attrs.find {|a| a.name == 'b'}
    expect(b_attribute.array?).to be_falsey
  end

  it 'gets attributes' do
    xml = '<a attr-1="1"> <b><foo attr-2="2"/></b>'
    builder = RoxmlBuilder.new(Nokogiri::XML(xml).root)
    new_classes = builder.build_classes
    a = new_classes[:A].new
    foo = new_classes[:Foo].new
    expect(a.respond_to? :attr1).to be_truthy
    expect(foo.respond_to? :attr2).to be_truthy
    a.attr1 = "1"
    foo.attr2 = "2"
    a.b = new_classes[:B].new
    a.b.foo = foo
    doc = a.to_xml
    expect(doc.xpath('@attr-1')[0].value).to eq('1')
    expect(doc.xpath('b/foo/@attr-2')[0].value).to eq('2')
  end


  it 'foo' do
    class Quux
      include ROXML
      # xml_accessor :element
      xml_accessor :a
      xml_accessor :b
    end
    class RoxmlTest
      include ROXML
      xml_name 'roxml-test'
      xml_accessor :foo
      xml_accessor :quuxes, as: [Quux]
      # xml_accessor :quux, as: {value: 'quux' }
    end

    xml = '<roxml-test><foo>1</foo><quuxes><quux><a>1</a><b>2</b></quux><quux><a>3</a><b>4</b></quux></quuxes></roxml-test>'
    t = RoxmlTest.from_xml(xml)
    expect(t).to be_truthy

  end

  it 'bar' do
    xml = '<a attr-1="foo" attr-2="bar"/>'
    doc = Nokogiri::XML(xml)

    puts doc.root.xpath('@*').inspect
  end
end