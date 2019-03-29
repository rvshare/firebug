# frozen_string_literal: true

module Firebug
  # Class for reading a string
  class StringIOReader < StringIO
    # Reads data from the buffer until +char+ is found.
    #
    # @param [String] char The character to look for.
    # @param [Boolean] include If +char+ should be included in the result.
    # @return [String, nil]
    def read_until(char, include: true)
      if (idx = string.index(char, pos)) # rubocop:disable Style/GuardClause
        read(idx - pos + (include ? 1 : 0))
      end
    end
  end
end
