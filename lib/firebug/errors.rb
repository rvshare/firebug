# frozen_string_literal: true

module Firebug
  class ParseError < StandardError
    attr_accessor :parser

    def initialize(msg, parser)
      super(msg)
      self.parser = parser
    end
  end

  class UnknownTokenError < ParseError
  end

  class IntegerParseError < ParseError
  end

  class DoubleParseError < ParseError
  end

  class BooleanParseError < ParseError
  end
end
