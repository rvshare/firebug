# frozen_string_literal: true

module Firebug
  class Unserializer
    attr_accessor :str

    def initialize(string)
      self.str = StringScanner.new(string)
    end

    def self.parse(value)
      new(value).parse
    end

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

    def parse_enumerable # rubocop:disable AbcSize
      size = parse_int
      expect('{')
      return [] if size.zero?
      if str.peek(1) == 'i'
        # Odd number element will be the index value so drop it.
        Array.new(size * 2) { parse }.select.with_index { |_, i| i.odd? }
      else
        Array.new(size) { [parse.to_sym, parse] }.to_h
      end
    end

    def parse_string
      size = parse_int
      str.getch # quote
      read(size).tap { str.getch }
    end

    def parse_int
      str.scan(/:(\d+):?/)
      raise ParserError, "Failed to parse integer at position #{str.pos}" unless str.matched?
      str[1].to_i
    end

    def parse_double
      str.scan(/:(\d+(?:\.\d+)?)/)
      raise ParserError, "Failed to parse double at position #{str.pos}" unless str.matched?
      str[1].to_f
    end

    def parse_bool
      str.scan(/:([01])/)
      raise ParserError, "Failed to parse boolean at position #{str.pos}" unless str.matched?
      str[1] == '1'
    end

    def read(size)
      Array.new(size) { str.get_byte }.join
    end

    def expect(s)
      char = str.getch
      raise ParserError, "expected '#{s}' but got '#{char}' at position #{str.pos}" if char != s
    end
  end

  class ParserError < StandardError
  end
end
