# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe Firebug::Session do
  let(:firebug_spy) { class_spy(Firebug).as_stubbed_const }
  let(:model) do
    described_class.create!(
      session_id: SecureRandom.hex,
      last_activity: Time.current.to_i,
      user_agent: 'Testing',
      ip_address: '127.0.0.1'
    )
  end

  before do
    Firebug.configure do |config|
      config.key = 'password'
      config.table_name = 'ci_sessions'
    end

    allow(firebug_spy).to receive(:unserialize).with(String).and_return(Hash)
    allow(firebug_spy).to receive(:serialize).with(Object).and_return(String)
    allow(firebug_spy).to receive(:encrypt_cookie).with(Hash).and_return(String)
  end

  describe '#user_data' do
    it 'calls Firebug.unserialize' do
      model.user_data
      expect(firebug_spy).to have_received(:unserialize)
    end
  end

  describe '#user_data=' do
    it 'calls Firebug.serialize' do
      model.user_data = { foo: 'bar' }
      expect(firebug_spy).to have_received(:serialize)
    end
  end

  describe '#user_agent=' do
    it 'truncates the value to 120 characters' do
      model.user_agent = 'x' * 130
      expect(model.user_agent.size).to eq(120)
    end
  end

  describe '#cookie_data' do
    it 'calls Firebug.encrypt_cookie' do
      model.cookie_data
      expect(firebug_spy).to have_received(:encrypt_cookie)
    end
  end

  # This is mostly just to get 100% test coverage.
  describe '#timestamp_attributes_for_update' do
    it 'returns array containing "last_activity"' do
      expect(model.send(:timestamp_attributes_for_update)).to match_array(['last_activity'])
    end
  end
end
