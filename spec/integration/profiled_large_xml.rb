require './spec/spec_helper'
require './spec/fixtures'
xml = fixture('large_td.xml')
runtime = DslRuntime.new
runtime.populate_raw xml

