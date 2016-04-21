require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'ruby-prof'
require './lib/roundtrip_xml'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :profile do
  xml = File.read 'spec/fixtures/super-large.xml'
  # xml = File.read 'spec/fixtures/super-large.xml'
  result = RubyProf.profile do
    runtime = DslRuntime.new
    runtime.populate_raw xml, :healthRule
  end

  printer = RubyProf::GraphHtmlPrinter.new result
  file = File.new('-profile.html', 'w')
  printer.print file
  file.close

end