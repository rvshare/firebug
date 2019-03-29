# frozen_string_literal: true

module Firebug
  # Base error class.
  FirebugError = Class.new(StandardError)
  # An error unserializing a string.
  ParserError = Class.new(FirebugError)
end
