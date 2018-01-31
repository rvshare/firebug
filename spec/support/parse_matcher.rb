# frozen_string_literal: true

RSpec::Matchers.define :parse do |input|
  as = result = nil

  chain(:as) { |expected_output=nil| as = expected_output }

  match do |parser|
    begin
      result = parser.parse(input)
      as == result || as.nil?
    rescue StandardError
      false
    end
  end
end
