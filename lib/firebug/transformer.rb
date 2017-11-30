# frozen_string_literal: true

module Firebug
  class Transformer < Parslet::Transform
    rule(string: simple(:string))   { string.to_s }
    rule(integer: simple(:integer)) { integer.to_i }
    rule(float: simple(:float))     { float.to_f }
    rule(bool: simple(:bool))       { bool == '1' }
    rule(null: simple(:null))       { nil }
    rule(blank: simple(:blank))     { '' } # should this return nil?

    # array element
    rule(integer: simple(:int), value: simple(:value)) { value }
    # hash pair
    rule(key: simple(:key), value: subtree(:value))    { [key.to_sym, value] }

    rule(array: sequence(:array)) { array }
    rule(hash: subtree(:hash))    { hash.to_h }

    # empty array
    rule(array: 'a:0:{}') { [] }
  end
end
