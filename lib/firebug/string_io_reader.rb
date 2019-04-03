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
      # because UTF-8 is a variable-length encoding and +String#index+ returns the character index, not the byte index,
      # we use +String#b+ to convert the string to ASCII-8BIT. This forces Ruby to treat each byte as a single
      # character. This is needed because we have to know how many bytes from +pos+ the +char+ is.
      if (idx = string.b.index(char, pos)) # rubocop:disable Style/GuardClause
        read(idx - pos + (include ? 1 : 0))
      end
    end
  end
end
