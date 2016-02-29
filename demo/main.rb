require '../demo/dsl_runtime'
# inst = AContainer.new
# inst.evaluate_file('./dsl.rb')
# puts inst.get_el.to_xml
a_containers = Dir.glob('a-containers/*.xml')
runtime = DslRuntime.new
runtime.populate(a_containers)
obj = runtime.evaluate_file('./dsl.rb', :a_container)
puts obj
