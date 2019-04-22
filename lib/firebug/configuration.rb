# frozen_string_literal: true

module Firebug
  # A configuration object.
  #
  # @attr [String] key
  #   The encryption key used to encrypt and decrypt cookies.
  # @attr [String] table_name
  #   The name of the sessions table.
  # @attr [Boolean] truncate_user_agent
  #   Truncate the user-agent to 120 characters.
  # @attr [Proc] match_user_agent
  #   Use the user-agent in addition to the session ID.
  # @attr [Proc] match_ip_address
  #   Use the remote ip address in addition to the session ID.
  # @attr [Boolean] silence_logger
  #   Silence ActiveRecord logs.
  # @attr [Proc] session_filter
  #   Return true if this request should have it's session written.
  #   @see ActionDispatch::Session::CodeIgniterStore#commit_session?
  class Configuration
    attr_reader :table_name
    attr_reader :match_user_agent
    attr_reader :match_ip_address

    attr_accessor :key
    attr_accessor :truncate_user_agent
    attr_accessor :session_filter
    attr_accessor :silence_logger

    def initialize
      self.truncate_user_agent = false
      self.match_user_agent = false
      self.match_ip_address = false
      self.silence_logger = true
      # default to always writing the session
      self.session_filter = ->(_) { true }
    end

    # @param [Proc,Boolean] value
    def match_user_agent=(value)
      @match_user_agent = value.respond_to?(:call) ? value : ->(_) { value }
    end

    # @param [Proc,Boolean] value
    def match_ip_address=(value)
      @match_ip_address = value.respond_to?(:call) ? value : ->(_) { value }
    end

    # Sets the table name for (see Firebug::Session)
    #
    # @param [String] value
    def table_name=(value)
      Firebug::Session.table_name = value
      @table_name = value
    end
  end
end
