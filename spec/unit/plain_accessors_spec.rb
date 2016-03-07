require './spec/spec_helper'

describe 'plain accessor' do
  it 'adds accessors to list and they work' do
    class Foo
      include PlainAccessors
      plain_accessor :a
      plain_accessor :b
    end

    foo = Foo.new
    foo.a= 1
    foo.b= 2
    expect(Foo.plain_accessors.size).to eq 2
  end
end