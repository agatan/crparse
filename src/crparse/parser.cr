require "./parser/*"
require "./result"

module Crparse
  extend self

  def run(parser, input)
    state = State.new(input, 0)
    parser.run(state)
  end

  def char(ch)
    WrapParser.new(CharParser.new(ch))
  end

  def string(str)
    WrapParser.new(StringParser.new(str))
  end

  def any
    WrapParser.new(AnyParser.new)
  end

  def eof
    WrapParser.new(EOFParser.new)
  end
end
