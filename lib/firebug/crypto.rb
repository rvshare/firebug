# frozen_string_literal: true

module Firebug
  require 'digest'
  require 'securerandom'
  require 'mcrypt'

  # Class for encrypting and decrypting Pyro cookies.
  class Crypto
    # @param [String] key
    def initialize(key)
      @key = Digest::MD5.hexdigest(key)
    end

    # Encrypts +data+ using the Rijndael 256 cipher.
    #
    # @param [String] data
    # @return [String]
    def encrypt(data)
      # Create a random 32 byte string to act as the initialization vector.
      iv = SecureRandom.random_bytes(32)
      # Pyro pads the data with zeros
      cipher = FirebugMcrypt.new(:rijndael_256, :cbc, @key, iv, :zeros)
      add_noise(iv + cipher.encrypt(data))
    end

    # Decrypts +data+ using the Rijndael 256 cipher.
    #
    # @param [String] data
    # @return [String]
    def decrypt(data)
      data = remove_noise(data)
      # The first 32 bytes of the data is the original IV
      iv = data[0..31]
      cipher = FirebugMcrypt.new(:rijndael_256, :cbc, @key, iv, :zeros)
      cipher.decrypt(data[32..-1])
    end

    # Pyro adds "noise" to the results of the encryption by adding the ordinal value of each character with a
    # value in the key. The plaintext key is hashed with MD5 then SHA1.
    #
    # @param [String] data
    def add_noise(data)
      noise(data, :+)
    end

    # The "noise" is removed by subtracting the ordinals.
    #
    # @see #add_noise
    #
    # @param [String] data
    # @return [String]
    def remove_noise(data)
      noise(data, :-)
    end

    private

    # @param [String] data
    # @param [Symbol] operator
    # @return [String]
    def noise(data, operator)
      key = Digest::SHA1.hexdigest(@key)
      Array.new(data.size) { |i| (data[i].ord.send(operator, key[i % key.size].ord) % 256).chr }.join
    end
  end

  # To prevent warnings about @opened being uninitialized.
  class FirebugMcrypt < ::Mcrypt
    def initialize(algorithm, mode, key=nil, iv=nil, padding=nil) # rubocop:disable UncommunicativeMethodParamName
      @opened = nil
      super
    end
  end
end
