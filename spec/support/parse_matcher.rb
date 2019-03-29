# frozen_string_literal: true

RSpec::Matchers.define :parse do |input|
  as = nil

  chain(:as) { |expected_output=nil| as = expected_output }

  match do |parser|
    result = parser.parse(input)
    expect(result).to(eq(as)) if as
    true
  rescue StandardError
    false
  end
end
