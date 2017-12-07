# frozen_string_literal: true

module Firebug
  class Parser < Parslet::Parser
    rule(:digit)    { match('[0-9]') }
    rule(:digits)   { digit.repeat(1) }
    rule(:digits?)  { digit.repeat }
    rule(:quote)    { str('"') }
    rule(:nonquote) { str('"').absnt? >> any }
    rule(:escape)   { str('\\') >> any }
    rule(:sep)      { str(':') }
    rule(:term)     { str(';') }

    rule(:str_start) { str('s') >> sep >> digits.capture(:size) >> sep >> str('"') }
    rule(:str_end)   { str('"') >> term }
    rule(:string)    { str_start >> str_dynamic >> str_end }
    rule(:str_dynamic) do
      dynamic do |s, c|
        # Need to use the previous captured size to get a string of that length.
        str_size = c.captures[:size].to_i
        # Since we are dynamically creating a matcher, we don't want to advance the pointer of the string because we
        # need Parslet to match against it.
        # So we consume the size of the string then reset the internal +StringScanner+ of +Parslet::Source+ to it's
        # pre-consume position. Resetting the position inside #tap to avoid a temp variable.
        str(s.consume(str_size).tap { s.instance_variable_get(:@str).unscan }).as(:string)
      end
    end

    rule(:float_start) { str('d') >> sep }
    rule(:float_end)   { term }
    rule(:float)       { float_start >> (digits >> str('.').maybe >> digits?).as(:float) >> float_end }

    rule(:int_start) { str('i') >> sep }
    rule(:int_end)   { term }
    rule(:integer)   { int_start >> digits.as(:integer) >> int_end }

    rule(:bool_start) { str('b') >> sep }
    rule(:bool_end)   { term }
    rule(:bool)       { bool_start >> (str('0') | str('1')).as(:bool) >> bool_end }

    rule(:null)  { str('N') >> term }
    rule(:blank) { match('^$') }

    rule(:value) { string | integer | float | bool | null.as(:null) | blank.as(:blank) }

    rule(:enum_start) { str('a').repeat(1) >> sep >> digits >> sep >> str('{') }
    rule(:enum_end)   { str('}') }
    rule(:array_list) { integer >> object.as(:value) }
    rule(:hash_pair)  { string.as(:key) >> object.as(:value) }
    rule(:array)      { enum_start >> array_list.repeat >> enum_end }
    rule(:hash)       { enum_start >> hash_pair.repeat >> enum_end }

    rule(:object) { value | array.as(:array) | hash.as(:hash) }
    root(:object)
  end
end
