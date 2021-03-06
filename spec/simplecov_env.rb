# frozen_string_literal: true

require 'simplecov'

module SimpleCovEnv
  def start!
    configure_profile
    SimpleCov.start
  end

  def configure_profile
    formatters = [SimpleCov::Formatter::HTMLFormatter]

    SimpleCov.configure do
      formatter SimpleCov::Formatter::MultiFormatter.new(formatters)
      # Don't run coverage on the spec folder.
      add_filter 'spec'
    end
  end

  module_function :start!, :configure_profile
end
