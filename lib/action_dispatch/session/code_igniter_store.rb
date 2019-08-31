# frozen_string_literal: true

module ActionDispatch # :nodoc:
  module Session # :nodoc:
    require 'action_dispatch'
    require 'firebug/session'

    # A session store for Rails to handle Pyro sessions.
    class CodeIgniterStore < AbstractStore
      # The key name used to store the session model in the request env.
      SESSION_RECORD_KEY = 'rack.session.record'
      # The request env hash key that has the logger instance.
      ACTION_DISPATCH_LOGGER_KEY = 'action_dispatch.logger'

      # @param [Object] app
      # @param [Hash] options
      # @option options [String] :key ('default_pyrocms') The session cookie name.
      def initialize(app, options={})
        super(app, { key: 'default_pyrocms' }.merge(options))
      end

      private

      # Finds an existing session or creates a new one.
      #
      # @!visibility public
      #
      # @see http://api.rubyonrails.org/classes/ActionDispatch/Request.html ActionDispatch::Request
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Array<String, Hash>]
      def find_session(req, sid)
        silence_logger(req) do
          model = find_session_model(req, sid)
          req.env[SESSION_RECORD_KEY] = model
          # +Rack::Session::Abstract::Persisted#load_session+ expects this to return an Array with the first value being
          # the session ID and the second the actual session data.
          [model.session_id, model.user_data]
        end
      end

      # Should the session be persisted?
      #
      # @note This is called from +Rack::Session::Abstract::Persisted#commit_session+.
      #
      # @!visibility public
      #
      # @see http://www.rubydoc.info/gems/rack/Rack/Session/Abstract/Persisted#commit_session-instance_method
      #   Rack::Session::Abstract::Persisted#commit_session
      # @see http://api.rubyonrails.org/classes/ActionDispatch/Request.html ActionDispatch::Request
      #
      # @param [ActionDispatch::Request] req
      # @param [Hash] session
      # @param [Hash] options
      # @return [Boolean] when true #write_session will be called
      def commit_session?(req, session, options)
        # If session_filter returns true then let super decide if we commit the session.
        Firebug.config.session_filter.call(req) ? super : false
      end

      # Writes the session information to the database.
      #
      # @!visibility public
      #
      # @see http://api.rubyonrails.org/classes/ActionDispatch/Request.html ActionDispatch::Request
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @param [Hash] session
      # @param [Hash] _options
      # @return [String, FalseClass] encrypted and base64 encoded string of the session data or +false+ if the
      #   session could not be saved.
      def write_session(req, sid, session, _options)
        silence_logger(req) do
          model = find_session_model(req, sid)
          model_params = {
            session_id: model.session_id,
            user_agent: req.user_agent || '', # user_agent can't be null
            ip_address: req.remote_ip || '',  # ip_address can't be null
            user_data: session
          }
          # Returning false will cause Rack to output a warning.
          return false unless model.update(model_params)

          req.env[SESSION_RECORD_KEY] = model
          # Return the encrypted cookie format of the data. Rack sets this value as the cookie in the response
          model.cookie_data
        end
      end

      # Deletes then creates a new session in the database.
      #
      # @!visibility public
      #
      # @see http://api.rubyonrails.org/classes/ActionDispatch/Request.html ActionDispatch::Request
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @param [Hash] options
      # @return [String, nil] the new session id or +nil+ if +options[:drop]+.
      def delete_session(req, sid, options)
        silence_logger(req) do
          # Get the current database record for this session then delete it.
          find_session_model(req, sid).delete
          return if options[:drop]

          req.env[SESSION_RECORD_KEY] = nil
          # Generate a new one and return it's ID
          find_session_model(req).tap { |s| s.save if options[:renew] }.session_id
        end
      end

      # Tries to find the session ID in the requests cookies.
      #
      # @!visibility public
      #
      # @see http://api.rubyonrails.org/classes/ActionDispatch/Request.html ActionDispatch::Request
      #
      # @param [ActionDispatch::Request] req
      # @return [String, nil]
      def extract_session_id(req)
        sid = req.cookies[@key]
        # the request didn't have the session cookie so create a new session ID.
        return generate_sid if sid.nil?
        # sometimes the cookie contains just the session ID.
        return sid if sid.size <= 32

        Firebug.decrypt_cookie(sid)[:session_id]
      end

      # Attempts to find an existing session record or returns a new one.
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Firebug::Session]
      def find_session_model(req, sid=nil)
        if sid
          model = req.env[SESSION_RECORD_KEY] || Firebug::Session.find_by(find_by_params(req, sid))
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

      # The parameters used to find a session in the database.
      #
      # @param [ActionDispatch::Request] req
      # @param [String] sid
      # @return [Hash]
      def find_by_params(req, sid)
        params = { session_id: sid }
        params[:ip_address] = req.remote_ip if Firebug.config.match_ip_address.call(req)
        if Firebug.config.match_user_agent.call(req)
          params[:user_agent] = Firebug.config.truncate_user_agent ? req.user_agent&.slice(0...120) : req.user_agent
        end
        params
      end

      # If silence logger is enabled, disable logger output for the block.
      #
      # @param [ActionDispatch::Request] req
      def silence_logger(req)
        logger = req.env[ACTION_DISPATCH_LOGGER_KEY] || ActiveRecord::Base.logger
        if logger.respond_to?(:silence) && Firebug.config.silence_logger
          logger.silence { yield }
        else
          yield
        end
      end
    end
  end
end
