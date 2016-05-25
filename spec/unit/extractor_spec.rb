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
    def convert_roxml_obj_helper(obj, template)
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule, &obj).get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime, :HealthRules, &template
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

    it 'doesn\'t converts object to template with parameter when value isn\'t available' do

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
  end
end


