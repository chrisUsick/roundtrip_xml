require './spec/spec_helper'
require 'pp'

describe 'extractor' do

  describe '.new' do
    it 'creates instance of definition' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime do
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
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime do
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
    it 'diffs' do
      runtime = DslRuntime.new
      runtime.populate_raw fixture('healthrules01.xml')
      obj = runtime.evaluate_raw('', :HealthRule) do
        enabled true
        description 'foo'
      end.get_el
      extractor = Extractor.new [runtime.fetch(:HealthRule).new], runtime do
        define :BaseHealthrule, :HealthRule do
          enabled true
        end
      end

      defin = extractor.instance_variable_get(:@definitions)[:HealthRule][0]
      diffs = extractor.diff_definition(defin, obj)
      expect(diffs[0].key).to eq :description
      expect(diffs[0].obj_val).to eq 'foo'
    end
  end
end