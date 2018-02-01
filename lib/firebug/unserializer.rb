# frozen_string_literal: true

module Firebug
  require 'strscan'

  # This class will unserialize a PHP serialized string into a ruby object.
  #
  # @note Hashes will be returned with symbolized keys.
  #
  # @attr [StringScanner] str
  class Unserializer
    attr_accessor :str

    # @param [String] string
    def initialize(string)
      self.str = StringScanner.new(string)
    end

    # Convenience method for unserializing a PHP serialized string.
    #
    # @param [String] value
    # @return [Object]
    def self.parse(value)
      new(value).parse
    end

    # @raise [ParserError]
    def parse # rubocop:disable AbcSize,CyclomaticComplexity
      ch = str.getch
      return if ch.nil?

      case ch
      when 'a'
        parse_enumerable.tap { expect('}') }
      when 's'
        parse_string.tap { expect(';') }
      when 'i'
        parse_int.tap { expect(';') }
      when 'd'
        parse_double.tap { expect(';') }
      when 'b'
        parse_bool.tap { expect(';') }
      when 'N'
        expect(';')
      else
        raise ParserError, "Unknown token '#{ch}' at position #{str.pos}"
      end
    end

    private

    # @raise [ParseError]
    # @return [Hash, Array]
    def parse_enumerable # rubocop:disable AbcSize
      size = parse_int
      expect('{')
      return [] if size.zero?
      if str.peek(1) == 'i'
        # Multiply the size by 2 since the array index isn't counted in the size.
        # Odd number element will be the index value so drop it.
        Array.new(size * 2) { parse }.select.with_index { |_, i| i.odd? }
      else
        Array.new(size) { [parse.to_sym, parse] }.to_h
      end
    end

    # @return [String]
    def parse_string
      size = parse_int
      str.getch # consume quote '"'
      read(size).tap { str.getch }
    end

    # @raise [ParserError]
    # @return [Integer]
    def parse_int
      str.scan(/:(\d+):?/)
      raise ParserError, "Failed to parse integer at position #{str.pos}" unless str.matched?
      str[1].to_i
    end

    # @raise [ParserError]
    # @return [Float]
    def parse_double
      str.scan(/:(\d+(?:\.\d+)?)/)
      raise ParserError, "Failed to parse double at position #{str.pos}" unless str.matched?
      str[1].to_f
    end

    # @raise [ParserError]
    # @return [Boolean]
    def parse_bool
      str.scan(/:([01])/)
      raise ParserError, "Failed to parse boolean at position #{str.pos}" unless str.matched?
      str[1] == '1'
    end

    # @param [Integer] size
    # @return [String]
    def read(size)
      Array.new(size) { str.get_byte }.join
    end

    # @param [String] s
    # @raise [ParserError] if the next character is not `s`
    def expect(s)
      char = str.getch
      raise ParserError, "expected '#{s}' but got '#{char}' at position #{str.pos}" unless char == s
    end
  end

  class ParserError < StandardError
  end
end
