require './spec/spec_helper'

describe 'SexpDslBuilder' do
  it 'does stuff' do
    s = SexpDslBuilder.new
    pp s.exp
  end
end