# frozen_string_literal: true

module Firebug
  class Configuration
    attr_reader :table_name

    attr_accessor :key

    def table_name=(value)
      Firebug::Session.table_name = value
      @table_name = value
    end
  end
end
