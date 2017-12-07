# frozen_string_literal: true

require 'parslet'

require_relative 'firebug/version'
require_relative 'firebug/crypto'
require_relative 'firebug/serializer'
require_relative 'firebug/unserializer'
require_relative 'firebug/configuration'
require_relative 'firebug/parser'
require_relative 'firebug/transformer'
require_relative 'action_dispatch/session/code_igniter_store'

module Firebug
  class << self
    attr_writer :configuration
  end

  # @return [Firebug::Configuration]
  def self.configuration
    @configuration ||= Configuration.new
  end

  # @yieldparam [Firebug::Configuration] config
  def self.configure
    yield configuration
  end

  # Serialize a ruby object into a PHP serialized string.
  #
  # @param [Object] value
  # @return [String]
  def self.serialize(value)
    Serializer.parse(value)
  end

  # Unserialize a PHP serialized string into a ruby object.
  #
  # @param [String] value
  # @return [Object]
  def self.unserialize(value)
    Unserializer.parse(value)
  end

  # Encrypt data the way CodeIgniter does.
  #
  # @param [Object] data
  # @param [String] key
  def self.encrypt(data, key=nil)
    key = configuration.key if key.nil?
    Crypto.new(key).encrypt(data)
  end

  # Decrypt data encrypted using CodeIgniters encryption.
  #
  # @param [Object] data
  # @param [String] key
  def self.decrypt(data, key=nil)
    key = configuration.key if key.nil?
    Crypto.new(key).decrypt(data)
  end

  # Serializes, encrypts, and base64 encodes the data.
  #
  # @param [Object] data
  # @return [String] a base64 encoded string
  def self.encrypt_cookie(data)
    Base64.strict_encode64(Firebug.encrypt(Firebug.serialize(data)))
  end

  # Decodes the base64 encoded string, decrypts, and unserializes.
  #
  # @param [String] data a base64 encoded encrypted string
  # @return [Object] the unserialized data
  def self.decrypt_cookie(data)
    Firebug.unserialize(Firebug.decrypt(Base64.strict_decode64(data)))
  end
end
