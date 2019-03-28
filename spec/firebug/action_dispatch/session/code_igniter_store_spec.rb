# frozen_string_literal: true

require_relative '../../../spec_helper'

# Convert all the private methods into public ones so it's easier to test.
class ActionDispatch::Session::CodeIgniterStore
  private_instance_methods(false).each(&method(:public))
end

RSpec.describe ActionDispatch::Session::CodeIgniterStore do
  let(:app) { spy }

  before do
    Firebug.configure do |config|
      config.key = 'password'
      config.table_name = 'ci_sessions'
      config.match_user_agent = false
      config.match_ip_address = false
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
    let(:user_data) { { username: 'foobar' } }

    before do
      Firebug::Session.create!(
        session_id: session_id,
        last_activity: Time.current.to_i,
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        user_data: user_data
      )
    end

    it 'returns an array' do
      expect(store.find_session(request, session_id)).to be_an(Array)
    end

    it 'returns correct array elements' do
      expect(store.find_session(request, session_id)).to match_array([String, Hash])
    end

    context 'when there is an existing session' do
      it 'returns the session ID' do
        expect(store.find_session(request, session_id)).to include(session_id)
      end

      it 'returns the session user_data' do
        expect(store.find_session(request, session_id)).to include(user_data)
      end
    end

    context 'when match_user_agent is false and match_ip_address is false' do
      before do
        Firebug.configuration.match_user_agent = false
        Firebug.configuration.match_ip_address = false
      end

      it 'returns same session for different user-agent' do
        request.user_agent = 'foobar'
        expect(store.find_session(request, session_id)).to include(session_id)
      end

      it 'returns same session for different ip address' do
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).to include(session_id)
      end

      it 'returns the same session for different user-agent and ip address' do
        request.user_agent = 'foobar'
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).to include(session_id)
      end
    end

    context 'when match_user_agent is true and match_ip_address is false' do
      before do
        Firebug.configuration.match_user_agent = true
        Firebug.configuration.match_ip_address = false
      end

      it 'returns a new session for different user-agent' do
        request.user_agent = 'foobar'
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end

      it 'returns same session for different ip address' do
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).to include(session_id)
      end

      it 'returns new session for different user-agent and ip address' do
        request.user_agent = 'foobar'
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end
    end

    context 'when match_user_agent is false and match_ip_address is true' do
      before do
        Firebug.configuration.match_user_agent = false
        Firebug.configuration.match_ip_address = true
      end

      it 'returns same session for different user-agent' do
        request.user_agent = 'foobar'
        expect(store.find_session(request, session_id)).to include(session_id)
      end

      it 'returns new session for different ip address' do
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end

      it 'returns new session for different user-agent and ip address' do
        request.user_agent = 'foobar'
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end
    end

    context 'when match_user_agent is true and match_ip_address is true' do
      before do
        Firebug.configuration.match_user_agent = true
        Firebug.configuration.match_ip_address = true
      end

      it 'returns new session for different user-agent' do
        request.user_agent = 'foobar'
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end

      it 'returns new session for different ip address' do
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end

      it 'returns new session for different user-agent and ip address' do
        request.user_agent = 'foobar'
        request.instance_variable_set(:@remote_ip, '127.0.0.2')
        expect(store.find_session(request, session_id)).not_to include(session_id)
      end
    end
  end

  describe '#commit_session?' do
    let(:request) { ActionDispatch::TestRequest.create }
    let(:store) { described_class.new(app) }
    let(:session) { {} }
    let(:options) { {} }

    it 'returns true' do
      expect(store.commit_session?(request, session, options)).to be(true)
    end

    context 'when session filter returns false' do
      before do
        Firebug.config.session_filter = ->(_) { false }
      end

      it 'returns false' do
        expect(store.commit_session?(request, session, options)).to be(false)
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

    it 'does not set user_agent to null' do
      Firebug::Session.create!(session_id: session_id, last_activity: Time.current.to_i, user_agent: 'Foobar',
                               ip_address: request.remote_ip, user_data: session)
      request.user_agent = nil
      expect { store.write_session(request, session_id, session, nil) }.not_to raise_error
    end

    it 'does not set the ip_address to null' do
      Firebug::Session.create!(session_id: session_id, last_activity: Time.current.to_i, user_agent: 'Foobar',
                               ip_address: request.remote_ip, user_data: session)
      request.remote_addr = nil
      expect { store.write_session(request, session_id, session, nil) }.not_to raise_error
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
    let(:session_options) { {} }

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
      expect { store.delete_session(request, session_id, session_options) }.to(
        change { Firebug::Session.find_by(session_id: session_id) }.from(Firebug::Session).to(nil)
      )
    end

    it 'creates a new session' do
      # doesn't persist the new session so count goes down
      expect { store.delete_session(request, session_id, session_options) }.to(
        change { Firebug::Session.all.count }.by(-1)
      )
    end

    it 'returns a new session ID' do
      expect(store.delete_session(request, session_id, session_options)).not_to eq(session_id)
    end

    context 'when configured to drop' do
      before { session_options[:drop] = true }

      it 'returns nil' do
        expect(store.delete_session(request, session_id, session_options)).to be_nil
      end
    end

    context 'when configured to renew' do
      before { session_options[:renew] = true }

      it 'persists a new session' do
        expect { store.delete_session(request, session_id, session_options) }.to(
          change { Firebug::Session.last.session_id }
        )
      end
    end
  end

  describe '#extract_session_id' do
    let(:request) { ActionDispatch::TestRequest.create }
    let(:store) { described_class.new(app) }

    it 'returns new session ID when cookie is not found' do
      expect(store.extract_session_id(request)).to be_a(String)
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
