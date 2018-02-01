# frozen_string_literal: true

module Firebug
  require 'active_record'

  # An ActiveRecord model of the CodeIgniter sessions table.
  class Session < ActiveRecord::Base
    self.table_name = 'default_ci_sessions'

    # @return [Object]
    def user_data
      Firebug.unserialize(super || '')
    end

    # @param [Object] value
    def user_data=(value)
      super(Firebug.serialize(value))
    end

    # @return [String]
    def cookie_data
      data = { session_id: session_id, ip_address: ip_address, user_agent: user_agent, last_activity: last_activity }
      Firebug.encrypt_cookie(data)
    end
  end
end
