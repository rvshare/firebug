# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Firebug::Serializer do
  describe '.parse' do
    context 'when serializing primitives' do
      it 'serializes strings' do
        expect(described_class.parse('foo')).to eq('s:3:"foo";')
      end

      it 'serializes symbols' do
        expect(described_class.parse(:foo)).to eq('s:3:"foo";')
      end

      it 'serializes integers' do
        expect(described_class.parse(1)).to eq('i:1;')
      end

      it 'serializes floats' do
        expect(described_class.parse(1.5)).to eq('d:1.5;')
      end

      it 'serializes true' do
        expect(described_class.parse(true)).to eq('b:1;')
      end

      it 'serializes false' do
        expect(described_class.parse(false)).to eq('b:0;')
      end

      it 'serializes nils' do
        expect(described_class.parse(nil)).to eq('N;')
      end

      it 'serializes arrays' do
        expect(described_class.parse([])).to eq('a:0:{}')
      end

      it 'serializes hashes' do
        expect(described_class.parse({})).to eq('a:0:{}')
      end
    end

    context 'when serializing arrays' do
      it 'serializes an array of strings' do
        expect(described_class.parse(%w[foo bar])).to eq('a:2:{i:0;s:3:"foo";i:1;s:3:"bar";}')
      end

      it 'serializes an array of symbols' do
        expect(described_class.parse(%i[foo bar])).to eq('a:2:{i:0;s:3:"foo";i:1;s:3:"bar";}')
      end

      it 'serializes an array of integers' do
        expect(described_class.parse([1, 2, 3])).to eq('a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}')
      end

      it 'serializes an array of floats' do
        expect(described_class.parse([1.5, 2.8, 3.1])).to eq('a:3:{i:0;d:1.5;i:1;d:2.8;i:2;d:3.1;}')
      end

      it 'serializes an array of booleans' do
        expect(described_class.parse([true, true, false])).to eq('a:3:{i:0;b:1;i:1;b:1;i:2;b:0;}')
      end

      it 'serializes an array of arrays' do
        expect(described_class.parse(['foo', ['bar']])).to eq('a:2:{i:0;s:3:"foo";i:1;a:1:{i:0;s:3:"bar";}}')
      end
    end

    context 'when serializing hashes' do
      it 'serializes a hash with strings' do
        expect(described_class.parse(foo: 'bar', bar: 'foo')).to eq('a:2:{s:3:"foo";s:3:"bar";s:3:"bar";s:3:"foo";}')
      end

      it 'serializes a hash with symbols' do
        expect(described_class.parse(foo: :bar, bar: :foo)).to eq('a:2:{s:3:"foo";s:3:"bar";s:3:"bar";s:3:"foo";}')
      end

      it 'serializes a hash with integers' do
        expect(described_class.parse(foo: 1, bar: 2)).to eq('a:2:{s:3:"foo";i:1;s:3:"bar";i:2;}')
      end

      it 'serializes a hash with floats' do
        expect(described_class.parse(foo: 1.5, bar: 2.8)).to eq('a:2:{s:3:"foo";d:1.5;s:3:"bar";d:2.8;}')
      end

      it 'serializes a hash with booleans' do
        expect(described_class.parse(foo: true, bar: false)).to eq('a:2:{s:3:"foo";b:1;s:3:"bar";b:0;}')
      end

      it 'serializes a hash with a hash value' do
        expect(described_class.parse(foo: { bar: 'foo' })).to eq('a:1:{s:3:"foo";a:1:{s:3:"bar";s:3:"foo";}}')
      end
    end
  end
end
