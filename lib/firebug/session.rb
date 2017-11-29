# frozen_string_literal: true

require 'active_record/base'

module Firebug
  class Session < ActiveRecord::Base
    self.table_name = 'default_ci_sessions'

    def data
      { session_id: session_id, ip_address: ip_address, user_agent: user_agent, last_activity: last_activity }
    end

    def cookie_data
      Firebug.encrypt_cookie(data)
    end
  end
end
