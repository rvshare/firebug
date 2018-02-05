# frozen_string_literal: true

module Firebug
  # A configuration object.
  #
  # @attr [String] key the encryption key used to encrypt and decrypt cookies.
  # @attr [String] table_name the name of the sessions table.
  # @attr [Boolean] truncate_user_agent truncate the user-agent to 120 characters.
  # @attr [Boolean] match_user_agent use the user-agent in addition to the session ID.
  # @attr [Boolean] match_ip_address use the remote ip address in addition to the session ID.
  class Configuration
    attr_reader :table_name

    attr_accessor :key
    attr_accessor :truncate_user_agent
    attr_accessor :match_user_agent
    attr_accessor :match_ip_address

    # Sets the table name for +Firebug::Session+
    #
    # @param [String] value
    def table_name=(value)
      Firebug::Session.table_name = value
      @table_name = value
    end
  end
end
