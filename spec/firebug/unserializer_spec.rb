# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Firebug::Unserializer do
  context 'when parsing empty values' do
    it 'can parse an empty string' do
      expect(described_class).to parse('').as(nil)
    end
  end

  context 'when parsing strings' do
    it 'can parse a string' do
      expect(described_class).to parse('s:3:"foo";').as('foo')
    end

    it 'can parse a string of strings' do
      expect(described_class).to parse('s:13:"{"foo":"bar"}";').as('{"foo":"bar"}')
    end
  end

  context 'when parsing unicode strings' do
    it 'can parse them correctly' do
      expect(described_class).to parse('s:3:"√";').as('√')
    end
  end

  context 'when parsing integers' do
    it 'can parse an integer value' do
      expect(described_class).to parse('i:42;').as(42)
    end
  end

  context 'when parsing floats' do
    it 'can parse a float without a decimal' do
      expect(described_class).to parse('d:5;').as(5.0)
    end

    it 'can parse a float value' do
      expect(described_class).to parse('d:478.164;').as(478.164)
    end

    it 'can parse a float with a 0 decimal' do
      expect(described_class).to parse('d:9.0;').as(9.0)
    end
  end

  context 'when parsing booleans' do
    it 'can parse a true value' do
      expect(described_class).to parse('b:1;').as(true)
    end

    it 'can parse a false value' do
      expect(described_class).to parse('b:0;').as(false)
    end
  end

  context 'when parsing nulls' do
    it 'can parse null value' do
      expect(described_class).to parse('N;').as(nil)
    end

    it 'wont parse an invalid null' do
      expect { described_class.parse('n;') }.to raise_error(Firebug::ParserError)
    end
  end

  context 'when parsing arrays' do
    it 'can parse an empty array' do
      expect(described_class).to parse('a:0:{}').as({})
    end

    it 'can parse an array of strings' do
      expect(described_class).to parse('a:1:{i:0;s:3:"foo";}').as(['foo'])
    end

    it 'can parse an array of integers' do
      expect(described_class).to parse('a:1:{i:0;i:42;}').as([42])
    end

    it 'can parse an array of floats' do
      expect(described_class).to parse('a:1:{i:0;d:42.5;}').as([42.5])
    end

    it 'can parse an array of booleans' do
      expect(described_class).to parse('a:1:{i:0;b:0;}').as([false])
    end

    it 'can parse an array of nulls' do
      expect(described_class).to parse('a:1:{i:0;N;}').as([nil])
    end

    it 'can parse an array of arrays' do
      expect(described_class).to parse('a:1:{i:0;a:0:{}}').as([{}])
    end

    it 'can parse an array of mixed types' do
      expect(described_class).to parse('a:3:{i:0;s:3:"foo";i:1;i:42;i:2;d:42.5;}').as(['foo', 42, 42.5])
    end
  end

  context 'when parsing hashes' do
    it 'can parse an empty hash' do
      expect(described_class).to parse('a:0:{}').as({})
    end

    it 'can parse a hash with string values' do
      expect(described_class).to parse('a:1:{s:3:"foo";s:3:"bar";}').as(foo: 'bar')
    end

    it 'can parse a hash with integer values' do
      expect(described_class).to parse('a:1:{s:3:"foo";i:42;}').as(foo: 42)
    end

    it 'can parse a hash with float values' do
      expect(described_class).to parse('a:1:{s:3:"foo";d:42.5;}').as(foo: 42.5)
    end

    it 'can parse a hash with boolean values' do
      expect(described_class).to parse('a:1:{s:3:"foo";b:1;}').as(foo: true)
    end

    it 'can parse a hash with null values' do
      expect(described_class).to parse('a:1:{s:3:"foo";N;}').as(foo: nil)
    end

    it 'can parse a hash with array values' do
      expect(described_class).to parse('a:1:{s:3:"foo";a:1:{i:0;i:5;}}').as(foo: [5])
    end

    it 'can parse a hash with hash values' do
      expect(described_class).to parse('a:1:{s:3:"foo";a:1:{s:3:"bar";i:42;}}').as(foo: { bar: 42 })
    end

    it 'can parse a hash with mixed type values' do
      expect(described_class).to parse('a:3:{s:1:"a";s:3:"bar";s:1:"b";i:1;s:1:"c";b:0;}').as(a: 'bar', b: 1, c: false)
    end
  end
end
