# frozen_string_literal: true

RSpec::Matchers.define :parse do |input|
  as = nil

  chain(:as) { |expected_output=nil| as = expected_output }

  match do |parser|
    begin
      result = parser.parse(input)
      expect(result).to(eq(as)) if as
      true
    rescue StandardError
      false
    end
  end

  failure_message do |actual|
    if as
      String.new("Expected #{actual} to parse #{input} as #{as} but got #{actual.parse(input)}", 'utf-8')
    else
      "Expected #{actual} to parse #{input}"
    end
  end
end
