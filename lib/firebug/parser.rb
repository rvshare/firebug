# frozen_string_literal: true

module Firebug
  class Parser < Parslet::Parser
    rule(:digit)          { match('[0-9]') }
    rule(:digits)         { digit.repeat(1) }
    rule(:digits?)        { digit.repeat }
    rule(:quote)          { str('"') }
    rule(:nonquote)       { str('"').absnt? >> any }
    rule(:escape)         { str('\\') >> any }
    rule(:sep)            { str(':') }
    rule(:term)           { str(';') }
    # matches 's:3:"foo";'
    rule(:string_header)  { str('s').repeat(1) >> sep >> digits >> sep }
    rule(:string)         { string_header >> quote >> (escape | nonquote).repeat(1).as(:string) >> quote >> term }
    # matches 'd:1.5;'
    rule(:float_header)   { str('d').repeat(1) >> sep }
    rule(:float)          { float_header >> (digits >> str('.').maybe >> digits?).as(:float) >> term }
    # matches 'i:1;'
    rule(:integer_header) { str('i').repeat(1) >> sep }
    rule(:integer)        { integer_header >> digits.as(:integer) >> term }
    # matches 'b:1;'
    rule(:bool_header)    { str('b').repeat(1) >> sep }
    rule(:bool)           { bool_header >> (str('0') | str('1')).as(:bool) >> term }
    # matches 'N;'
    rule(:null)           { str('N').repeat(1) >> term }

    rule(:value)          { string | integer | float | bool | null.as(:null) }
    # matches 'i:0;s:3:"foo";'
    rule(:array_list)     { integer >> object.as(:value) }
    # matches 's:3:"foo";i:1;'
    rule(:hash_pair)      { string.as(:key) >> object.as(:value) }

    rule(:enum_header)    { str('a').repeat(1) >> sep >> digits >> sep }
    # matches 'a:2:{i:0;s:3:"foo";}'
    rule(:array)          { enum_header >> str('{') >> array_list.repeat >> str('}') }
    # matches 'a:2:{s:3:"foo";i:1;}'
    rule(:hash)           { enum_header >> str('{') >> hash_pair.repeat >> str('}') }

    rule(:object)         { value | array.as(:array) | hash.as(:hash) }
    root(:object)
  end
end
