# frozen_string_literal: true

require_relative '../spec_helper'
require 'parslet/rig/rspec'

RSpec.describe Firebug::Parser do
  let(:parser) { described_class.new }

  context 'when parsing empty values' do
    let(:blank_parser) { parser.blank }

    it 'can parse an empty string' do
      expect(blank_parser).to parse('')
    end
  end

  context 'when parsing strings' do
    let(:string_parser) { parser.string }

    it 'can parse a string' do
      expect(string_parser).to parse('s:3:"foo";')
    end
  end

  context 'when parsing integers' do
    let(:integer_parser) { parser.integer }

    it 'can parse an integer value' do
      expect(integer_parser).to parse('i:42;')
    end
  end

  context 'when parsing floats' do
    let(:float_parser) { parser.float }

    it 'can parse a float without a decimal' do
      expect(float_parser).to parse('d:5;')
    end

    it 'can parse a float value' do
      expect(float_parser).to parse('d:478.164;')
    end

    it 'can parse a float with a 0 decimal' do
      expect(float_parser).to parse('d:9.0;')
    end

    it 'wont parse an integer as a float' do
      expect(float_parser).not_to parse('i:42;')
    end
  end

  context 'when parsing booleans' do
    let(:bool_parser) { parser.bool }

    it 'can parse a true value' do
      expect(bool_parser).to parse('b:1;')
    end

    it 'can parse a false value' do
      expect(bool_parser).to parse('b:0;')
    end
  end

  context 'when parsing nulls' do
    let(:null_parser) { parser.null }

    it 'can parse null value' do
      expect(null_parser).to parse('N;')
    end

    it 'wont parse an invalid null' do
      expect(null_parser).not_to parse('n;')
    end
  end

  context 'when parsing arrays' do
    let(:array_parser) { parser.array }

    it 'can parse an empty array' do
      expect(array_parser).to parse('a:0:{}')
    end

    it 'can parse an array of strings' do
      expect(array_parser).to parse('a:1:{i:0;s:3:"foo";}')
    end

    it 'can parse an array of integers' do
      expect(array_parser).to parse('a:1:{i:0;i:42;}')
    end

    it 'can parse an array of floats' do
      expect(array_parser).to parse('a:1:{i:0;d:42.5;}')
    end

    it 'can parse an array of booleans' do
      expect(array_parser).to parse('a:1:{i:0;b:0;}')
    end

    it 'can parse an array of nulls' do
      expect(array_parser).to parse('a:1:{i:0;N;}')
    end

    it 'can parse an array of arrays' do
      expect(array_parser).to parse('a:1:{i:0;a:0:{}}')
    end

    it 'can parse an array of mixed types' do
      expect(array_parser).to parse('a:3:{i:0;s:3:"foo";i:1;i:42;i:2;d:42.5;}')
    end
  end

  context 'when parsing hashes' do
    let(:hash_parser) { parser.hash }

    it 'can parse an empty hash' do
      expect(hash_parser).to parse('a:0:{}')
    end

    it 'can parse a hash with string values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";s:3:"bar";}')
    end

    it 'can parse a hash with integer values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";i:42;}')
    end

    it 'can parse a hash with float values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";d:42.5;}')
    end

    it 'can parse a hash with boolean values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";b:1;}')
    end

    it 'can parse a hash with null values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";N;}')
    end

    it 'can parse a hash with array values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";a:1:{i:0;i:5;}}')
    end

    it 'can parse a hash with hash values' do
      expect(hash_parser).to parse('a:1:{s:3:"foo";a:1:{s:3:"bar";i:42;}}')
    end

    it 'can parse a hash with mixed type values' do
      expect(hash_parser).to parse('a:3:{s:1:"a";s:3:"bar";s:1:"b";i:1;s:1:"c";b:0;}')
    end
  end
end
