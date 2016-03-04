require './spec/spec_helper'

describe 'dsl_builder' do
  it 'creates child attributes' do
    xml = '<a><b>1</b><c>2</c></a>'
    runtime = DslRuntime.new
    runtime.populate_raw xml
    b = DslBuilder.new xml, runtime, :A
    out = b.to_dsl
    expect(out).to match /b 1/
    expect(out).to match /c 2/
  end

  it 'handles nested elements' do
    xml = '<a><b><ba>1</ba><bb>1.1</bb></b><d>2</d></a>'
    runtime = DslRuntime.new
    runtime.populate_raw xml
    b = DslBuilder.new xml, runtime, :A
    out = b.to_dsl
    expect(out).to match 'b do'
    expect(out).to match '  ba 1'
    expect(out).to match '  bb 1.1'
    expect(out).to match 'd 2'
  end

  it 'handles array elements' do
    xml = '<a><b><foo>1</foo></b> <b><foo>2</foo></b></a>'
    runtime = DslRuntime.new
    runtime.populate_raw xml
    b = DslBuilder.new xml, runtime, :A
    out = b.to_dsl
    expect(out).to match '  foo 1'
    expect(out).to match '  foo 2'

  end

  it 'handles a complex example' do
    xml = '<a><b><ba>1</ba><bb><bba>1.1</bba></bb></b><b><ba>1.2</ba><bb><bba>1.3</bba></bb></b><d><da><daa><daaa>2</daaa></daa></da></d></a>'
    runtime = DslRuntime.new
    runtime.populate_raw xml
    b = DslBuilder.new xml, runtime, :A
    out = b.to_dsl
    expected = <<-EXPECTED
b do
  ba '1'
  bb do
    bba '1.1'
  end
end

b do
  ba '1.2'
  bb do
    bba '1.3'
  end
end

d do
  da do
    daa do
      daaa '2'
    end
  end
end
    EXPECTED
    expect(out).to eq(expected)
  end
end