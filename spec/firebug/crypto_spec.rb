# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Firebug::Crypto do
  describe '.new' do
    it 'supports keys larger than 32 bytes' do
      expect { described_class.new(SecureRandom.random_bytes(64)) }.not_to raise_error
    end
  end

  describe '#encrypt' do
    let(:cipher) { described_class.new('password') }

    it 'returns different results for same inputs' do
      sample = 'foo'
      expect(cipher.encrypt(sample)).not_to eq(cipher.encrypt(sample))
    end
  end

  describe '#decrypt' do
    let(:cipher) { described_class.new('password') }

    it 'can decrypt previously encrypted data' do
      encrypted_text = Base64.strict_decode64('RqAVBiB3PFynwfbQ6onB5ZeQQUA4EsOXspBllGIm36M64JjBWdOhnNoJykcKj+26BtTgilBYQZYf/nwbxS+QTg==')
      expect(cipher.decrypt(encrypted_text)).to eq('foo')
    end
  end
end
