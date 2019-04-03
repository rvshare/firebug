# frozen_string_literal: true

module Firebug
  # Base error class.
  Error = Class.new(StandardError)
  # An error unserializing a string.
  ParserError = Class.new(Error)
end
