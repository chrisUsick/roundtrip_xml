require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'ruby-prof'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :profile do

  RubyProf.start
  runtime = DslRuntime.new
  runtime.populate_raw xml
end