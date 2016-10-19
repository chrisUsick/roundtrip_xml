require './spec/spec_helper'
require 'pp'

describe 'extractor' do

  describe '.new' do
    it 'creates instance of definition' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule do
          enabled true
        end
      end

      obj = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      expect(obj.enabled).to be_truthy
    end

    it 'creates instance of n-level subclass definition' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule do
          enabled true
        end

        define :BTHealthrule, :BaseHealthrule do
          type 'BT'
        end
      end

      obj = extractor.instance_variable_get(:@definitions)[:HealthRule][1]
      expect(obj.enabled).to be_truthy
      expect(obj.type).to eq 'BT'
    end
  end

  describe '#diff_definition' do
    it 'diffs simple template' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule do
          enabled true
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq :description
      expect(diffs[0].obj_val).to eq 'foo'
    end

    it 'diffs parameterized template' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule, :descript do
          description descript
          enabled true
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq :description
      expect(diffs[0].obj_val).to eq 'foo'
      expect(diffs[0].template_val).to be_an_instance_of Utils::UndefinedParam
    end

    it 'diffs element with missing object attribute' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
          entityAggregationScope do
            type 'ALL'
          end
        end
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule, :descript do
          description descript
          enabled true
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq :criticalExecutionCriteria
      expect(diffs[1].key).to eq :description
      expect(diffs[1].obj_val).to eq 'foo'
      expect(diffs[1].template_val).to be_an_instance_of Utils::UndefinedParam
    end

    it 'matches deep nested objects' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
          entityAggregationScope do
            type 'ALL'
          end
        end
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule, :descript do
          description descript
          enabled true
          criticalExecutionCriteria do
            entityAggregationScope do
              type 'ALL'
            end
          end
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq :description
      expect(diffs[0].obj_val).to eq 'foo'
      expect(diffs[0].template_val).to be_an_instance_of Utils::UndefinedParam
    end

    it 'finds nested differences' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
          entityAggregationScope do
            type 'NONE'
          end
        end
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule, :descript do
          description descript
          enabled true
          criticalExecutionCriteria do
            entityAggregationScope do
              type 'ALL'
            end
          end
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq 'criticalExecutionCriteria.entityAggregationScope.type'.to_sym
    end

    it 'finds nested parameters' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
          entityAggregationScope do
            type 'NONE'
          end
        end
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules do
        define :BaseHealthrule, :HealthRule, :aggregate_type do
          enabled true
          criticalExecutionCriteria do
            entityAggregationScope do
              type aggregate_type
            end
          end
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq 'criticalExecutionCriteria.entityAggregationScope.type'.to_sym
      expect(diffs[0].template_val).to be_an_instance_of Utils::UndefinedParam
    end
  end

  describe '#convert_roxml_obj' do
    def convert_roxml_obj_helper(obj, template, obj_class = :HealthRule)
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules02.xml')
      if obj.is_a? String
        obj = runtime.evaluate_file(obj, obj_class).get_el
      else
        obj = runtime.evaluate_raw('', obj_class, &obj).get_el
      end
      extractor = Extractor.new nil, runtime, :HealthRules, &template
      [runtime, obj, extractor]
    end

    it 'converts nested object to a template with no parameters' do
      obj = Proc.new do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
          entityAggregationScope do
            type 'NONE'
          end
        end
      end
      template = Proc.new do
        define :BaseHealthrule, :HealthRule do
          enabled true
        end
      end

      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template
      new_obj = extractor.convert_roxml_obj roxml_obj
      expect(new_obj.class.class_name).to eq :BaseHealthrule
      expect(new_obj.description).to eq 'foo'
      expect(new_obj.criticalExecutionCriteria).to be_an_instance_of(runtime.fetch(:CriticalExecutionCriteria))
      expect(new_obj.criticalExecutionCriteria.entityAggregationScope.type).to eq 'NONE'
    end

    it 'adds simple properties not defined on the template but defined on the obj' do
      obj = Proc.new do
        healthRule do
          enabled true
          description 'foo'
          criticalExecutionCriteria do
            entityAggregationScope do
              type 'NONE'
              value '0'
            end
          end
        end
      end
      template = Proc.new do
        define :Scope, :EntityAggregationScope do
          type 'NONE'
        end

        define :BaseHealthrule, :HealthRule do
          enabled true
        end
      end

      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template, :HealthRules
      new_obj = extractor.convert_roxml_obj roxml_obj
      expect(new_obj.class.class_name).to eq :HealthRules
      expect(new_obj.healthRule[0].criticalExecutionCriteria.entityAggregationScope.class.class_name).to eq :Scope
      expect(new_obj.healthRule[0].criticalExecutionCriteria.entityAggregationScope.value).to eq '0'

    end

    it 'converts nested object to template with parameter' do

      obj = Proc.new do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
          entityAggregationScope do
            type 'NONE'
          end
        end
      end
      template = Proc.new do
        define :BaseHealthrule, :HealthRule, :aggregate_type do
          enabled true
          criticalExecutionCriteria do
            entityAggregationScope do
              type aggregate_type
            end
          end
        end
      end

      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template
      new_obj = extractor.convert_roxml_obj roxml_obj
      expect(new_obj.class.class_name).to eq :BaseHealthrule
      expect(new_obj.description).to eq 'foo'
      expect(new_obj.aggregate_type).to eq 'NONE'
    end

    it 'doesnt converts object to template with parameter when value isnt available' do

      obj = Proc.new do
        enabled true
        description 'foo'
        criticalExecutionCriteria do
        end
      end
      template = Proc.new do
        define :BaseHealthrule, :HealthRule, :aggregate_type do
          enabled true
          criticalExecutionCriteria do
            entityAggregationScope do
              type aggregate_type
            end
          end
        end
      end

      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template
      new_obj = extractor.convert_roxml_obj roxml_obj
      expect(new_obj).to eq roxml_obj
    end

    it 'refactors an element with multiple children' do

      obj = Proc.new do
        healthRule do
          enabled true
          description 'foo'
        end
        healthRule do
          enabled true
          description 'bar'
        end
        healthRule do
          enabled true
          description 'baz'
        end
      end
      template = Proc.new do
        define :BaseHealthrule, :HealthRule do
          enabled true
        end
      end

      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template, :HealthRules
      healthrules = extractor.convert_roxml_obj(roxml_obj).healthRule

      expect(healthrules.size).to eq 3
      healthrules.each do |r|
        expect(r).to be_an_instance_of(runtime.fetch(:BaseHealthrule))
      end
    end




    it 'matches multiple parameters' do
      obj = Proc.new do
        type 'leaf'
        functionType 'VALUE'
        value '0'
        isLiteralExpression 'false'
        displayName 'null'
        metricDefinition do
          type 'LOGICAL_METRIC'
          logicalMetricName 'Average Response Time (ms)'
        end
      end

      template = Proc.new do
        define :BasicExpression, :MetricExpression, :function, :metric_name do
          type 'leaf'
          functionType function
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName metric_name
          end
        end
      end

      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template, :MetricExpression
      basic = extractor.convert_roxml_obj roxml_obj
      expect(basic.function).to eq 'VALUE'
      expect(basic.metric_name).to eq 'Average Response Time (ms)'
    end

    it 'converts multiple templates per element' do
      obj = fixture_path 'refactorable-dsl.rb'
      template = Proc.new do
        define :BasicExpression, :MetricExpression, :function, :metric_name do
          type 'leaf'
          functionType function
          value '0'
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName metric_name
          end
        end
      end
      runtime, roxml_obj, extractor = convert_roxml_obj_helper obj, template, :HealthRules
      health_rules = extractor.convert_roxml_obj roxml_obj
      rule = health_rules.healthRule[2]
      expect(rule.criticalExecutionCriteria.policyCondition.metricExpression).to be_an_instance_of runtime.fetch(:BasicExpression)
      expect(rule.warningExecutionCriteria.policyCondition.metricExpression).to be_an_instance_of runtime.fetch(:BasicExpression)

    end

    it 'handles deep attributes' do
      runtime = DslRuntime.new
      xml = fixture 'healthrules03.xml'
      runtime.populate_raw xml
      obj = runtime.fetch(:HealthRule).from_xml fixture('app-components.xml')
      extractor = Extractor.new [obj], runtime, :HealthRule, [fixture('_templates.rb')]
      new_obj = extractor.convert_roxml_objs
      components = new_obj[0].affectedEntitiesMatchCriteria.affectedBtMatchCriteria.applicationComponents.applicationComponent
      expect(components.size).to eq 19
      components.each do |c|
        expect(c).to be_an_instance_of String
      end
    end

    it 'diffs interpolated strings' do
      obj = Proc.new do
        type 'leaf thingy'
        functionType 'VALUE'
        value 'aa >= b'
        isLiteralExpression 'false'
        displayName 'null'
        metricDefinition do
          type 'LOGICAL_METRIC'
          logicalMetricName 'the Average Response Time (ms)'
        end
      end

      template = Proc.new do
        define :BasicExpression, :MetricExpression, :metric_type, :op, :function, :metric_name do
          _matcher :metric_name, /(.*)$/
          type "#{metric_type} thingy"
          functionType function
          value "aa #{op} b"
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName "the #{metric_name}"
          end
        end
      end

      _, roxml_obj, extractor = convert_roxml_obj_helper obj, template, :MetricExpression
      basic = extractor.convert_roxml_obj roxml_obj
      expect(basic.function).to eq 'VALUE'
      expect(basic.metric_type).to eq 'leaf'
      expect(basic.op).to eq '>='
      expect(basic.metric_name).to eq 'Average Response Time (ms)'
    end
  end

  describe '#eval_definitions' do
    it 'identifies definitions once they are already in the dsl' do
      obj = Proc.new do
        type 'leaf thingy'
        functionType 'VALUE'
        value 'aa >= b'
        isLiteralExpression 'false'
        displayName 'null'
        metricDefinition do
          type 'LOGICAL_METRIC'
          logicalMetricName 'the Average Response Time (ms)'
        end
      end

      template = Proc.new do
        define :BasicExpression, :MetricExpression, :metric_type, :op, :function, :metric_name do
          _matcher :metric_name, /(.*)$/
          type "#{metric_type} thingy"
          functionType function
          value "aa #{op} b"
          isLiteralExpression 'false'
          displayName 'null'
          metricDefinition do
            type 'LOGICAL_METRIC'
            logicalMetricName "the #{metric_name}"
          end
        end
      end

      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules02.xml')

      roxml_obj = runtime.evaluate_raw('', :MetricExpression, &obj).get_el
      runtime.evaluate_raw '', :MetricExpression, &template
      extractor = Extractor.new nil, runtime, :HealthRules, &template

      basic = extractor.convert_roxml_obj roxml_obj
      expect(basic).to be_an_instance_of(runtime.fetch(:BasicExpression))
    end
  end
end


