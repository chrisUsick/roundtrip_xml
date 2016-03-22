require './spec/fixtures'
require './lib/roundtrip_xml/roxml_builder'
require 'nokogiri'
require './lib/roundtrip_xml/dsl_runtime'
require 'nokogiri/diff'
require './lib/roundtrip_xml/dsl_builder'
require './lib/roundtrip_xml/plain_accessors'

def element_nodes_match_text (a, b)
  a.children.each do |el|

  end
end