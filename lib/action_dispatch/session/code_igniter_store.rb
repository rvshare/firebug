# frozen_string_literal: true

require 'action_dispatch'
require_relative '../../firebug/session'

module ActionDispatch
  module Session
    class CodeIgniterStore < AbstractStore
      def initialize(app, options={})
        super(app, { key: 'default_pyrocms' }.merge(options))
      end

      # @param [ActionDispatch::Request] req
      # @param [Hash] sid
      def find_session(req, sid)
        model = find_session_model(req, sid)
        # +Rack::Session::Abstract::Persisted#load_session+ expects this to return an Array with the first value being
        # the session ID and the second the actual session data.
        [model.session_id, model.user_data]
      end

      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @param [Hash] session
      # @param [Hash] _options
      # @return [String]
      def write_session(req, sid, session, _options)
        model = find_session_model(req, sid)
        model_params = {
          session_id: model.session_id,
          user_agent: req.user_agent,
          ip_address: req.remote_ip,
          user_data: session,
          last_activity: Time.current.to_i
        }
        # Returning false will cause Rack to output a warning.
        return false unless model.update(model_params)
        # Return the encrypted cookie format of the data. Rack sets this value as the cookie in the response
        model.cookie_data
      end

      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @param [Hash] _options
      # @return [String] the new session id
      def delete_session(req, sid, _options)
        # Get the current database record for this session then delete it.
        find_session_model(req, sid).delete
        # Generate a new one and return it's ID
        find_session_model(req).session_id
      end

      # @param [ActionDispatch::Request] req
      # @return [String, nil]
      def extract_session_id(req)
        sid = req.cookies[@key]
        return if sid.nil?
        return sid if sid.size <= 32
        Firebug.decrypt_cookie(sid)[:session_id]
      end

      private

      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Firebug::Session]
      def find_session_model(req, sid=nil)
        if sid
          model = Firebug::Session.find_by(session_id: sid)
          return model if model
        end

        Firebug::Session.create!(
          session_id: sid || generate_sid,
          last_activity: Time.current.to_i,
          user_agent: req.user_agent,
          ip_address: req.remote_ip
        )
      end
    end
  end
end
