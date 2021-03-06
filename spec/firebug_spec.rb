# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Firebug do
  it 'has a version number' do
    expect(Firebug::VERSION).not_to be_nil
  end

  describe '.configure' do
    let(:key) { 'password' }

    it 'yields the configuration' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(Firebug::Configuration)
    end

    it 'sets the key in configure block' do
      described_class.configure { |config| config.key = key }
      expect(described_class.configuration.key).to eq(key)
    end

    it 'sets the table name for Firebug::Sessions' do
      expect { described_class.configuration.table_name = 'foo' }.to(
        change(Firebug::Session, :table_name).from(Firebug::Session.table_name).to('foo')
      )
    end
  end

  describe '.serialize' do
    let(:test_case) { { a: 'foo', b: 4, c: 1.5, d: true, e: nil, f: [1], g: { x: 'bar' } } }

    it 'serializes a ruby object' do
      expect(described_class.serialize(test_case)).to eq('a:7:{s:1:"a";s:3:"foo";s:1:"b";i:4;s:1:"c";d:1.5;s:1:"d";b:1;s:1:"e";N;s:1:"f";a:1:{i:0;i:1;}s:1:"g";a:1:{s:1:"x";s:3:"bar";}}')
    end

    context 'when serializing result of unserialize' do
      it 'produces the same value' do
        str_result = described_class.serialize(test_case)
        obj_result = described_class.unserialize(str_result)
        expect(described_class.serialize(obj_result)).to eq(str_result)
      end

      it 'produces same result after multiple rounds' do
        obj_result = described_class.unserialize(described_class.serialize(test_case))
        obj_result = described_class.unserialize(described_class.serialize(obj_result))
        obj_result = described_class.unserialize(described_class.serialize(obj_result))
        expect(described_class.serialize(obj_result)).to eq(described_class.serialize(test_case))
      end
    end
  end

  describe '.unserialize' do
    let(:test_case) { 'a:7:{s:1:"a";s:3:"foo";s:1:"b";i:4;s:1:"c";d:1.5;s:1:"d";b:1;s:1:"e";N;s:1:"f";a:1:{i:0;i:1;}s:1:"g";a:1:{s:1:"x";s:3:"bar";}}' }

    it 'unserializes to a ruby object' do
      expect(described_class.unserialize(test_case)).to eq(a: 'foo', b: 4, c: 1.5, d: true, e: nil, f: [1], g: { x: 'bar' })
    end

    context 'when unserializing result of serialize' do
      it 'produces the same value' do
        obj_result = described_class.unserialize(test_case)
        str_result = described_class.serialize(obj_result)
        expect(described_class.unserialize(str_result)).to eq(obj_result)
      end

      it 'produces same result after multiple rounds' do
        str_result = described_class.serialize(described_class.unserialize(test_case))
        str_result = described_class.serialize(described_class.unserialize(str_result))
        str_result = described_class.serialize(described_class.unserialize(str_result))
        expect(described_class.unserialize(str_result)).to eq(described_class.unserialize(test_case))
      end
    end
  end

  describe '.encrypt' do
    let(:key) { 'password' }
    let(:test_case) { 'Super secret data' }

    it 'encrypts data' do
      expect(described_class.encrypt(test_case, key)).not_to eq(test_case)
    end

    context 'when setting key using configuration' do
      before do
        described_class.configure do |config|
          config.key = key
        end
      end

      it 'decrypts data' do
        expect(described_class.encrypt(test_case)).not_to eq(test_case)
      end
    end
  end

  describe '.decrypt' do
    let(:key) { 'password' }
    let(:test_case) { Base64.strict_decode64('MhJ5SVXPve1H4Ej6iXdqFd12efNk8fpB4JttHzMNnIeLKhqjHvH6P2iYmyWgBealwo5sNweMUa+mPyYagULY5g==') }

    it 'decrypts data' do
      expect(described_class.decrypt(test_case, key)).to eq('Super secret data')
    end

    context 'when setting key using configuration' do
      before do
        described_class.configure do |config|
          config.key = key
        end
      end

      it 'decrypts data' do
        expect(described_class.decrypt(test_case)).to eq('Super secret data')
      end
    end
  end
end
