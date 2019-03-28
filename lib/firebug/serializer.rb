# frozen_string_literal: true

module Firebug
  # A class for converting a Ruby object into a PHP serialized string.
  class Serializer
    # Convert a ruby object into a PHP serialized string.
    #
    # @param [Object] obj
    # @raise [ArgumentError] for unsupported types
    # @return [String]
    def self.parse(obj) # rubocop:disable CyclomaticComplexity
      case obj
      when NilClass
        'N;'
      when TrueClass
        'b:1;'
      when FalseClass
        'b:0;'
      when Integer
        "i:#{obj};"
      when Float
        "d:#{obj};"
      when String, Symbol
        "s:#{obj.to_s.bytesize}:\"#{obj}\";"
      when Array
        "a:#{obj.length}:{#{obj.map.with_index { |e, i| "#{parse(i)}#{parse(e)}" }.join}}"
      when Hash
        "a:#{obj.length}:{#{obj.map { |k, v| "#{parse(k)}#{parse(v)}" }.join}}"
      else
        raise ArgumentError, "unsupported type #{obj.class.name}"
      end
    end
  end
end
