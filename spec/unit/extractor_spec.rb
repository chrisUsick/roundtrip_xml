require './spec/spec_helper'
require 'pp'

describe 'extractor' do

  describe '#similar_fields' do
    it 'only compares items once' do
      allow(HashDiff).to receive(:diff).and_return([])
      runtime = DslRuntime.new
      raw = fixture('refactorable-dsl.xml')
      runtime.populate_raw raw
      roxml_root = runtime.fetch(:HealthRules).from_xml raw
      root_method = :healthRule
      extractor = Extractor.new roxml_root.send(root_method), runtime

      extractor.similar_fields
      expect(HashDiff).to have_received(:diff).exactly(21).times
    end
  end
end