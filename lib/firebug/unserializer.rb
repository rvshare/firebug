# frozen_string_literal: true

module Firebug
  require_relative 'errors'
  require_relative 'string_io_reader'

  # This class will unserialize a PHP serialized string into a ruby object.
  #
  # @attr [StringIOReader] str
  class Unserializer
    attr_accessor :str

    # @param [String] string
    def initialize(string)
      self.str = StringIOReader.new(string)
    end

    # Convenience method for unserializing a PHP serialized string.
    #
    # @see #parse
    #
    # @param [String] value
    # @return [Object]
    def self.parse(value)
      new(value).parse
    end

    # Parse a PHP serialized string into a Ruby object.
    #
    # @note Hashes will be returned with symbolized keys.
    #
    # @raise [ParserError]
    # @return [Hash, Array, String, Integer, Float, nil]
    def parse
      ch = str.getc
      return if ch.nil?

      str.getc # : or ;
      case ch
      when 'a'
        parse_enumerable.tap { str.getc }
      when 's'
        parse_string
      when 'i'
        parse_int
      when 'd'
        parse_double
      when 'b'
        parse_bool
      when 'N'
        nil
      else
        raise ParserError, "Unknown token '#{ch}' at position #{str.pos} (#{str.string})"
      end
    end

    private

    # @raise [ParseError]
    # @return [Hash, Array]
    def parse_enumerable
      size = str.read_until('{')[0..-3].to_i # n:{
      return {} if size.zero?

      val = Array.new(size) { [parse, parse] }
      if val[0][0].is_a?(Integer)
        val.map! { |_, v| v }
      else
        val = Hash[val].transform_keys!(&:to_sym)
      end
      val
    end

    # @return [String]
    def parse_string
      size = str.read_until(':').to_i + 3 # add 3 for the 2 double quotes and semicolon
      String.new(str.read(size)[1..-3], encoding: Encoding::UTF_8)
    end

    # @raise [ParserError]
    # @return [Integer]
    def parse_int
      str.read_until(';')[0..-1].to_i
    end

    # @raise [ParserError]
    # @return [Float]
    def parse_double
      str.read_until(';')[0..-1].to_f
    end

    # @raise [ParserError]
    # @return [Boolean]
    def parse_bool
      str.read(2)[0] == '1'
    end
  end
end
