# frozen_string_literal: true

require_relative '../../../spec_helper'

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

  describe '#find_session' do
    let(:request) { ActionDispatch::TestRequest.create }
    let(:store) { described_class.new(app) }
    let(:session_id) { store.generate_sid }

    it 'returns an array' do
      expect(store.find_session(request, session_id)).to be_an(Array)
    end

    it 'returns correct array elements' do
      expect(store.find_session(request, session_id)).to match_array([String, nil])
    end

    context 'when there is an existing session' do
      let(:user_data) { { username: 'foobar' } }

      before do
        Firebug::Session.create!(
          session_id: session_id,
          last_activity: Time.current.to_i,
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          user_data: { username: 'foobar' }
        )
      end

      it 'returns the session ID' do
        expect(store.find_session(request, session_id)).to include(session_id)
      end

      it 'returns the session user_data' do
        expect(store.find_session(request, session_id)).to include(user_data)
      end
    end
  end

  describe '#write_session' do
    let(:request) { ActionDispatch::TestRequest.create }
    let(:store) { described_class.new(app) }
    let(:session_id) { store.generate_sid }
    let(:session) { { username: 'foobar' } }

    it 'returns a string' do
      expect(store.write_session(request, session_id, session, nil)).to be_a(String)
    end

    context 'when there is an existing session' do
      before do
        Firebug::Session.create!(
          session_id: session_id,
          last_activity: Time.current.to_i,
          user_agent: 'Foobar',
          ip_address: request.remote_ip,
          user_data: session
        )
      end

      it 'updates the session' do
        expect { store.write_session(request, session_id, session, nil) }.to(
          change { Firebug::Session.find(session_id).inspect }
        )
      end
    end

    context 'when there is not an existing session' do
      it 'creates a new session' do
        expect { store.write_session(request, session_id, session, nil) }.to(
          change { Firebug::Session.all.count }
        )
      end
    end
  end

  describe '#delete_session' do
    let(:request) { ActionDispatch::TestRequest.create }
    let(:store) { described_class.new(app) }
    let(:session_id) { store.generate_sid }

    before do
      Firebug::Session.create!(
        session_id: session_id,
        last_activity: Time.current.to_i,
        user_agent: 'Foobar',
        ip_address: request.remote_ip,
        user_data: { username: 'foobar' }
      )
    end

    it 'deletes the existing session' do
      expect { store.delete_session(request, session_id, nil) }.to(
        change { Firebug::Session.find_by(session_id: session_id) }.from(anything).to(nil)
      )
    end

    it 'creates a new session' do
      # count wont change since it deletes the old session and creates a new one.
      expect { store.delete_session(request, session_id, nil) }.not_to(
        change { Firebug::Session.all.count }
      )
    end

    it 'returns a new session ID' do
      expect(store.delete_session(request, session_id, nil)).not_to eq(session_id)
    end
  end

  describe '#extract_session_id' do
    let(:request) { ActionDispatch::TestRequest.create }
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
