# frozen_string_literal: true

module Firebug
  require 'digest'
  require 'securerandom'
  require 'mcrypt'

  class Crypto
    # @param [String] key
    def initialize(key)
      @key = Digest::MD5.hexdigest(key)
    end

    # @param [String] data
    # @return [String]
    def encrypt(data)
      # create a random 32 byte string
      iv = SecureRandom.random_bytes(32)
      # CodeIgniter pads the data with zeros
      cipher = Mcrypt.new(:rijndael_256, :cbc, @key, iv, :zeros)
      add_noise(iv + cipher.encrypt(data))
    end

    # @param [String] data
    # @return [String]
    def decrypt(data)
      data = remove_noise(data)
      # The first 32 bytes of the data is the original IV
      iv = data[0..31]
      cipher = Mcrypt.new(:rijndael_256, :cbc, @key, iv, :zeros)
      cipher.decrypt(data[32..-1])
    end

    # CodeIgniter adds "noise" to the results of the encryption by adding the ordinal value of each character with a
    # value in the key. The plaintext key is hashed with MD5 then SHA1.
    #
    # @param [String] data
    def add_noise(data)
      key = Digest::SHA1.hexdigest(@key)
      Array.new(data.size) { |i| ((data[i].ord + key[i % key.size].ord) % 256).chr }.join
    end

    # The "noise" is removed by subtracting the ordinals.
    #
    # @param [String] data
    # @return [String]
    def remove_noise(data)
      key = Digest::SHA1.hexdigest(@key)
      Array.new(data.size) { |i| ((data[i].ord - key[i % key.size].ord) % 256).chr }.join
    end
  end
end
