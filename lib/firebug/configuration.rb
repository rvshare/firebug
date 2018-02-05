# frozen_string_literal: true

module Firebug
  # A configuration object.
  #
  # @attr [String] key the encryption key used to encrypt and decrypt cookies.
  # @attr [String] table_name the name of the sessions table.
  # @attr [Boolean] truncate_useragent truncate the user-agent to 120 characters.
  class Configuration
    attr_reader :table_name

    attr_accessor :key
    attr_accessor :truncate_useragent

    # Sets the table name for +Firebug::Session+
    #
    # @param [String] value
    def table_name=(value)
      Firebug::Session.table_name = value
      @table_name = value
    end
  end
end
