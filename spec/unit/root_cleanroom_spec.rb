require './spec/spec_helper'

describe 'root_cleanroom' do
  it 'adds a definition to the runtime' do
    xml = <<-XML
<a><b>1</b><c><d>2</d></c></a>
    XML
    dsl = <<-DSL
define :CSub, :C, :d_val do
  d d_val + 1
end
b 1
c :CSub do
  d_val 1
end
    DSL

    runtime = DslRuntime.new
    runtime.populate_raw(xml)
    # modify class to have non xmla accessor attribute
    el = runtime.evaluate_raw(dsl, :A).get_el
    expect(el.c.d).to eq 2
  end

  it 'handles deeply nested elements' do
    xml = <<-XML
<a><b>1</b><c>
<d><e>2</e><f><g>3</g></f></d></c></a>
    XML

    runtime = DslRuntime.new
    runtime.populate_raw(xml)
    # modify class to have non xmla accessor attribute
    a_class = runtime.fetch(:A)
    el = runtime.evaluate_file(fixture_path('dsl_definitions.rb'), :A).get_el
    expect(el.c.d.e).to eq 2
    expect(el.c.d.f.g).to eq 3
  end

  it 'handles multiple subclasses' do
    xml = fixture('refactorable-dsl.xml')
    runtime = DslRuntime.new
    runtime.populate_raw(xml)

    res = runtime.evaluate_raw(nil, :HealthRules) do
      use_file './spec/fixtures/multiple-subclasses.rb'
      healthRule :CPUUtilization do
        crit_cpu_busy 90
        warn_cpu_busy 75
      end

    end
    root = res.get_el.to_xml
    root.css('logical-metric-name').each do |el|
      expect(el.content).to eq('Hardware Resources|CPU|%Busy')
    end

    expect(root.css('warning-execution-criteria condition-value')[0].content).to eq(75.to_s)
    expect(root.css('critical-execution-criteria condition-value')[0].content).to eq(90.to_s)

  end


  it 'handles multiple subclasses simple' do
    xml = fixture('refactorable-dsl.xml')
    runtime = DslRuntime.new
    runtime.populate_raw(xml)

    res = runtime.evaluate_raw(nil, :HealthRules) do
      define :BaseHealthRule, :HealthRule do
        enabled true
      end

      define :InfraMatchHealthRule, :BaseHealthRule,
             :env_props do
        affectedEntitiesMatchCriteria do
          affectedInfraMatchCriteria do
            type 'NODES'
            nodeMatchCriteria do
              type 'ANY'
              nodeMetaInfoMatchCriteria ''
              vmSysProperties ''
              envProperties env_props
            end
          end
        end
      end
      define :SpecificHealthRule, :InfraMatchHealthRule do
        env_props 'foo bar baz'
      end
      healthRule :SpecificHealthRule do
      end
    end

    res.get_el.to_xml.css('env-properties').each do |el|
      expect(el.content).to eq('foo bar baz')
    end


  end

  context 'top level templates' do
    let(:runtime) do
      xml = fixture('refactorable-dsl.xml')
      runtime = DslRuntime.new
      runtime.populate_raw(xml)
      runtime
    end
    it 'raises exception if the template doesnt extend the root class' do
      expect do
        runtime.evaluate_raw(nil, :HealthRules) do
          define :Foo, :PolicyCondition do
            type 'leaf'
          end

          apply_template :Foo
        end
      end.to raise_error(ArgumentError)


    end

    it 'applies a root template' do

      res = runtime.evaluate_raw(nil, :HealthRules) do
        define :DefaultRules, :HealthRules,
               :app, :rule1_status, :rule2_status do
          healthRule do
            name "#{app} - rule 1"
            enabled rule1_status
          end

          healthRule do
            name "#{app} - rule 2"
            enabled rule2_status
          end
        end
        apply_template :DefaultRules do
          app 'sample app'
          rule1_status true
          rule2_status false
        end
      end

      def rule_name(number)
        "sample app - rule #{number}"
      end

      rule1, rule2 = res.get_el.healthRule
      expect(res.get_el.to_xml.name).to eq 'health-rules'
      expect(rule1.name).to eq rule_name(1)
      expect(rule1.enabled).to be_truthy
      expect(rule2.name).to eq rule_name(2)
      expect(rule2.enabled).to be_falsey
    end
  end
end
