# frozen_string_literal: true

module Firebug
  require 'parslet'

  require_relative 'firebug/version'
  require_relative 'firebug/crypto'
  require_relative 'firebug/serializer'
  require_relative 'firebug/parser'
  require_relative 'firebug/transformer'

  # @param [String] value
  # @return [Object]
  def self.unserialize(value)
    Transformer.new.apply(Parser.new.parse(value))
  end

  # @param [Object] value
  # @return [String]
  def self.serialize(value)
    Serializer.parse(value)
  end

  def self.encrypt(key, data)
    Firebug::Crypto.new(key).encrypt(data)
  end

  def self.decrypt(key, data)
    Firebug::Crypto.new(key).decrypt(data)
  end
end
