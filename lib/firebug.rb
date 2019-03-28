# frozen_string_literal: true

require_relative 'firebug/version'
require_relative 'firebug/crypto'
require_relative 'firebug/errors'
require_relative 'firebug/serializer'
require_relative 'firebug/unserializer'
require_relative 'firebug/configuration'
require_relative 'action_dispatch/session/code_igniter_store'

module Firebug
  class << self
    attr_writer :configuration

    # Firebug configuration
    #
    # @return [Firebug::Configuration]
    def configuration
      @configuration ||= Configuration.new
    end
    alias config configuration

    # Configure Firebug inside a block.
    #
    # @example
    #   Firebug.configure do |config|
    #     config.key = 'password'
    #   end
    #
    # @yieldparam [Firebug::Configuration] config
    def configure
      yield configuration
    end

    # Serialize a ruby object into a PHP serialized string.
    #
    # @see Firebug::Serializer.parse
    #
    # @param [Object] value
    # @return [String]
    def serialize(value)
      Serializer.parse(value)
    end

    # Unserialize a PHP serialized string into a ruby object.
    #
    # @see Firebug::Unserializer.parse
    #
    # @param [String] value
    # @return [Object]
    def unserialize(value)
      Unserializer.parse(value)
    end

    # Encrypt data the way CodeIgniter does.
    #
    # @see Firebug::Crypto#encrypt
    #
    # @param [Object] data
    # @param [String] key if `nil` use +Firebug::Configuration.key+
    def encrypt(data, key=nil)
      Crypto.new(key.nil? ? config.key : key).encrypt(data)
    end

    # Decrypt data encrypted using CodeIgniters encryption.
    #
    # @see Firebug::Crypto#decrypt
    #
    # @param [Object] data
    # @param [String] key If `nil` use +Firebug::Configuration.key+
    def decrypt(data, key=nil)
      Crypto.new(key.nil? ? config.key : key).decrypt(data)
    end

    # Serializes, encrypts, and base64 encodes the data.
    #
    # @param [Object] data
    # @return [String] A base64 encoded string.
    def encrypt_cookie(data)
      Base64.strict_encode64(Firebug.encrypt(Firebug.serialize(data)))
    end

    # Decodes the base64 encoded string, decrypts, and unserializes.
    #
    # @param [String] data A base64 encoded encrypted string.
    # @return [Object] The unserialized data.
    def decrypt_cookie(data)
      data.nil? ? {} : Firebug.unserialize(Firebug.decrypt(Base64.strict_decode64(data)))
    end
  end
end
