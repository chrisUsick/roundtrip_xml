require './spec/spec_helper'

describe 'base_cleanroom' do
  it 'makes getters and setters for xml accessors' do
    xml = <<-XML
<a><b>1</b><c>2</c></a>
    XML
    dsl = <<-DSL
b 1
c b + 1
    DSL

    runtime = DslRuntime.new
    runtime.populate_raw(xml)
    actual = runtime.evaluate_raw(dsl, :A).get_el
    expect(actual.b).to eq 1
    expect(actual.c).to eq 2
  end

  it 'creates cleanroom methods for non xml accessors attributes' do
    xml = <<-XML
<a><b>1</b><c>2</c></a>
    XML
    dsl = <<-DSL
b 1
c b + 1
foo 'bar'
    DSL

    runtime = DslRuntime.new
    runtime.populate_raw(xml)
    # modify class to have non xmla accessor attribute
    a_class = runtime.fetch(:A)
    a_class.send(:plain_accessor, :foo)
    actual = runtime.evaluate_raw(dsl, :A).get_el
    expect(actual.b).to eq 1
    expect(actual.c).to eq 2
    expect(actual.foo).to eq 'bar'
  end

  describe '_metadata' do
    it 'stores metadata' do
      xml = fixture 'healthrules01.xml'
      runtime = DslRuntime.new
      runtime.populate_raw xml

      dsl = <<-DSL
healthRule do
  _metadata runbook: 'FOO'
end
      DSL

      actual = runtime.evaluate_raw(dsl, :HealthRules).get_el.healthRule
      expect(actual._metadata[:runbook]).to eq 'FOO'
    end
  end

  describe 'array of object elements' do
    it 'works' do
      xml = <<-XML
<affected-bt-match-criteria>
                <type>SPECIFIC</type>
                <business-transactions>
                    <business-transaction application-component="web">GET - /v2/players/weekprojectedstats</business-transaction>
                    <business-transaction application-component="web">GET - /v2/game/state</business-transaction>
                    <business-transaction application-component="web">GET - /v2/league/transactions</business-transaction>
</business-transactions>
</affected-bt-match-criteria>
      XML
      runtime = DslRuntime.new
      runtime.populate_raw xml
      dsl = <<RUBY
type 'SPECIFIC'
businessTransactions do
  businessTransaction do
    applicationComponent 'web'
    businessTransaction 'GET - /v2/players/weekprojectedstats'
  end
  businessTransaction do
    applicationComponent 'web'
    businessTransaction 'GET - /v2/game/state'
  end
  businessTransaction do
    applicationComponent 'web'
    businessTransaction 'GET - /v2/league/transactions'
  end
end
RUBY
      actual = runtime.evaluate_raw(dsl, :AffectedBtMatchCriteria).get_el
      expect(actual.businessTransactions.businessTransaction.size).to eq(3)
      actual.businessTransactions.businessTransaction.each {|bt| expect(bt).to respond_to(:businessTransaction)}
    end
  end
end