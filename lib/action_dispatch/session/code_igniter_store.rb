# frozen_string_literal: true

require 'action_dispatch'
require_relative '../../firebug/session'
require_relative '../../firebug/errors'

module ActionDispatch
  module Session
    class CodeIgniterStore < AbstractStore
      def initialize(app, options={})
        super(app, { key: 'default_pyrocms' }.merge(options))
      end

      # Finds an existing session or creates a new one.
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Array<String, Object>]
      def find_session(req, sid)
        model = find_session_model(req, sid)
        # +Rack::Session::Abstract::Persisted#load_session+ expects this to return an Array with the first value being
        # the session ID and the second the actual session data.
        [model.session_id, model.user_data]
      end

      # Writes the session information to the database.
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @param [Hash] session
      # @param [Hash] _options
      # @return [String] encrypted and base64 encoded string of the session data.
      def write_session(req, sid, session, _options)
        model = find_session_model(req, sid)
        model_params = {
          session_id: model.session_id,
          user_agent: req.user_agent || '', # user_agent can't be null
          ip_address: req.remote_ip || '',  # ip_address can't be null
          user_data: session
        }
        # Returning false will cause Rack to output a warning.
        return false unless model.update(model_params)
        # Return the encrypted cookie format of the data. Rack sets this value as the cookie in the response
        model.cookie_data
      end

      # Deletes then creates a new session in the database.
      #
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

      # Tries to find the session ID in the requests cookies.
      #
      # @param [ActionDispatch::Request] req
      # @return [String, nil]
      def extract_session_id(req)
        sid = req.cookies[@key]
        # returning `nil` just causes a new ID to be generated.
        return if sid.nil?
        # sometimes the cookie contains just the session ID.
        return sid if sid.size <= 32

        begin
          Firebug.decrypt_cookie(sid)[:session_id]
        rescue Firebug::UnknownTokenError => e
          # Since Pyro doesn't use a MAC we can't validate decryption. So if we get a parser error on the first
          # character we assume it's because the data wasn't decrypted correctly. If not it's probably something else.
          raise if e.parser.str.pos != 1
          req.get_header(Rack::RACK_ERRORS).puts(
            'Warning! Failed to decrypt session cookie, probably encrypted with a different key. Generating new session'
          )
          generate_sid
        end
      end

      private

      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Firebug::Session]
      def find_session_model(req, sid=nil)
        if sid
          model = Firebug::Session.find_by(find_by_params(req, sid))
          return model if model
          # use a different session ID in case the reason for not finding the record is because the user_agent
          # or ip_address didn't match.
          sid = generate_sid
        end

        Firebug::Session.new(
          session_id: sid || generate_sid,
          last_activity: Time.current.to_i,
          user_agent: req.user_agent,
          ip_address: req.remote_ip
        )
      end

      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Hash]
      def find_by_params(req, sid)
        params = { session_id: sid }
        params[:ip_address] = req.remote_ip if Firebug.configuration.match_ip_address
        if Firebug.configuration.match_user_agent
          params[:user_agent] = Firebug.configuration.truncate_user_agent ? req.user_agent[0...120] : req.user_agent
        end
        params
      end
    end
  end
end
