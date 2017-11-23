# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Firebug::Transformer do
  let(:parser) { Firebug::Parser.new }
  let(:transformer) { described_class.new }

  context 'when transforming strings' do
    it 'returns a ruby string' do
      result = parser.parse('s:3:"foo";')
      expect(transformer.apply(result)).to be_a(String)
    end

    it 'returns the correct value' do
      result = parser.parse('s:3:"bar";')
      expect(transformer.apply(result)).to eq('bar')
    end
  end

  context 'when transforming integers' do
    it 'returns a ruby integer' do
      result = parser.parse('i:42;')
      expect(transformer.apply(result)).to be_a(Integer)
    end

    it 'returns the correct value' do
      result = parser.parse('i:42;')
      expect(transformer.apply(result)).to eq(42)
    end
  end

  context 'when transforming floats' do
    it 'returns a ruby float' do
      result = parser.parse('d:42.5;')
      expect(transformer.apply(result)).to be_a(Float)
    end

    it 'returns the correct value' do
      result = parser.parse('d:42.5;')
      expect(transformer.apply(result)).to eq(42.5)
    end
  end

  context 'when transforming an array' do
    it 'returns a ruby array' do
      result = parser.parse('a:2:{i:0;s:3:"foo";i:1;s:3:"bar";}')
      expect(transformer.apply(result)).to be_a(Array)
    end
  end

  context 'when transforming a hash' do
    it 'returns a ruby array' do
      result = parser.parse('a:1:{s:3:"foo";s:3:"bar";}')
      expect(transformer.apply(result)).to be_a(Hash)
    end
  end
end
