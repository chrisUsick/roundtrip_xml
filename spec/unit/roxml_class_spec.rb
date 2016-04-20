require './spec/spec_helper'

include Utils
describe 'Utils::new_roxml_class' do
  describe '#to_hash' do
    it 'hashes a primative object' do
      clazz = new_roxml_class 'a'
      clazz.xml_accessor :b
      clazz.xml_accessor :c
      clazz.xml_accessor :d
      a = clazz.new
      a.b = 1
      a.c = 2
      a.d = 3
      hash = a.to_hash
      expect(hash).to include({'b' => 1, 'c' => 2, 'd' => 3})
    end

    it 'hashes a nested object' do
      a_class = new_roxml_class 'a'
      b_class = new_roxml_class 'b'
      a_class.xml_accessor :b, as: b_class
      b_class.xml_accessor :c
      a_class.xml_accessor :d
      a = a_class.new
      b = b_class.new
      a.b = b
      b.c = 2
      a.d = 3
      hash = a.to_hash
      expect(hash).to include({'b' => {'c' => 2}, 'd' => 3})
    end
  end
end
