# frozen_string_literal: true

RSpec::Matchers.define :parse do |input|
  as = result = trace = nil

  chain(:as) { |expected_output=nil| as = expected_output }

  match do |parser|
    begin
      result = parser.parse(input)
      as == result || as.nil?
    rescue StandardError => ex
      trace = ex.message
      false
    end
  end

  failure_message do |is|
    msg = if as
            "output of parsing #{input.inspect} with #{is.inspect} to equal #{as.inspect}, but was #{result.inspect}"
          else
            "#{is.inspect} to be able to parse #{input.inspect}"
          end
    "expected #{msg}#{trace ? "\n" + trace : ''}"
  end

  failure_message_when_negated do |is|
    msg = if as
            "output of parsing #{input.inspect} with #{is.inspect} not to equal #{as.inspect}"
          else
            "#{is.inspect} to not parse #{input.inspect}, but it did"
          end
    "expected #{msg}#{trace ? "\n" + trace : ''}"
  end
end
