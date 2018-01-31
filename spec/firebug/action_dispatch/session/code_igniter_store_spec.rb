# frozen_string_literal: true

require_relative '../../../spec_helper'
require 'action_dispatch/testing/test_request'

# TODO(Aaron): Figure out how to use `ActionDispatch::TestRequest`
RSpec.describe ActionDispatch::Session::CodeIgniterStore do
  let(:app) { spy.as_null_object }

  before do
    Firebug.configure do |config|
      config.key = 'password'
      config.table_name = 'ci_sessions'
    end
  end

  describe '.new' do
    it 'can overwrite default cookie key' do
      store = described_class.new(app, key: 'foo')
      expect(store.key).to eq('foo')
    end
  end

  xdescribe '#find_session' do
    let(:request) { ActionDispatch::TestRequest.create }
    let(:store) { described_class.new(app) }
    let(:session_id) { store.generate_sid }

    it 'returns an array' do
      expect(store.find_session(request, session_id)).to be_an(Array)
    end

    it 'sets first element to session ID'

    it 'sets second element to session data'

    context 'when there is an existing session' do
      it 'returns that session ID'

      it 'returns that session user_data'
    end

    context 'when there is not an existing session' do
      it 'creates a new session'
    end
  end

  describe '#write_session' do
    it 'returns the encrypted cookie value'

    context 'when there is an existing session' do
      it 'updates the session'
    end

    context 'when there is not an existing session' do
      it 'creates a new session'
    end
  end

  describe '#delete_session' do
    it 'deletes the existing session'

    it 'creates a new session'

    it 'returns a new session ID'
  end

  describe '#extract_session_id' do
    let(:request) { Rack::Request.new({}) }
    let(:store) { described_class.new(app) }

    it 'returns nil when cookie is not found' do
      expect(store.extract_session_id(request)).to be_nil
    end

    it 'returns cookie if it looks like session ID' do
      cookie = '7d153ee34a847de5bbf962a0fdb1c053'
      request.cookies[store.key] = cookie
      expect(store.extract_session_id(request)).to eq(cookie)
    end

    it 'returns session ID from encrypted cookie' do
      session_id = store.generate_sid
      request.cookies[store.key] = Firebug.encrypt_cookie(session_id: session_id)
      expect(store.extract_session_id(request)).to eq(session_id)
    end
  end
end
