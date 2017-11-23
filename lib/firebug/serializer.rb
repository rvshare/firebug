# frozen_string_literal: true

module Firebug
  class Serializer
    def self.parse(obj) # rubocop:disable AbcSize,CyclomaticComplexity
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
        "a:#{obj.length}:{#{obj.collect.with_index { |e, i| "#{parse(i)}#{parse(e)}" }.join}}"
      when Hash
        "a:#{obj.length}:{#{obj.collect { |k, v| "#{parse(k)}#{parse(v)}" }.join}}"
      else
        raise ArgumentError, "unsupported type #{obj.class.name}"
      end
    end
  end
end
