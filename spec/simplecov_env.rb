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
    end
  end

  module_function :start!, :configure_profile
end
