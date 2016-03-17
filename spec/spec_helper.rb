require './spec/fixtures'
require './lib/roundtrip/roxml_builder'
require 'nokogiri'
require './lib/roundtrip/dsl_runtime'
require 'nokogiri/diff'
require './lib/roundtrip/dsl_builder'
require './lib/roundtrip/plain_accessors'

def element_nodes_match_text (a, b)
  a.children.each do |el|

  end
end