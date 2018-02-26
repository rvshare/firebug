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
  # @attr [Boolean] match_user_agent
  #   Use the user-agent in addition to the session ID.
  # @attr [Boolean] match_ip_address
  #   Use the remote ip address in addition to the session ID.
  # @attr [Proc] session_filter
  #   Return true if this request should have it's session written.
  #   @see ActionDispatch::Session::CodeIgniterStore#commit_session?
  class Configuration
    attr_reader :table_name

    attr_accessor :key
    attr_accessor :truncate_user_agent
    attr_accessor :match_user_agent
    attr_accessor :match_ip_address
    attr_accessor :session_filter

    def initialize
      self.truncate_user_agent = false
      self.match_user_agent = false
      self.match_ip_address = false
      # default to always writing the session
      self.session_filter = ->(_) { true }
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
