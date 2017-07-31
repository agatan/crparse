require "../result"
require "../parser"

module Crparse::Parsers
  class FailParser(T) < Parser(T)
    def initialize(@message : String)
    end

    def run(state : State)
      Failure.new(@message, state)
    end
  end

  def fail(t : T.class, message) forall T
    FailParser(T).new(message)
  end

  class AnyParser < Parser(Char)
    def run(state : State)
      if state.input.bytesize > state.byte_offset
        ch = state.reader.current_char
        Success.new(ch, state.shift(ch))
      else
        Failure.new("expected any input", state)
      end
    end
  end

  def any
    AnyParser.new
  end

  class EOFParser < Parser(Nil)
    def run(state : State)
      if state.input.bytesize == state.byte_offset
        Success.new(nil, state)
      else
        Failure.new("expected EOF", state)
      end
    end
  end

  def eof
    EOFParser.new
  end

  class CharParser < Parser(Char)
    def initialize(@needle : Char)
    end

    def run(state : State)
      if state.reader.current_char == @needle
        Success.new(@needle, state.shift(@needle))
      else
        Failure.new("expected #{@needle.inspect}", state)
      end
    end
  end

  def char(ch)
    CharParser.new(ch)
  end

  class StringParser < Parser(String)
    def initialize(@needle : String)
    end

    def run(state : State)
      if state.string.starts_with?(@needle)
        Success.new(@needle, state.shift(@needle))
      else
        Failure.new("expected #{@needle.inspect}", state)
      end
    end
  end

  def string(str)
    StringParser.new(str)
  end

  class RangeParser < Parser(Char)
    def initialize(@range : Range(Char, Char))
    end

    def run(state : State)
      reader = state.reader
      return Failure.new("unexpected EOF", state) unless reader.has_next?
      if @range.includes?(reader.current_char)
        Success.new(reader.current_char, state.shift(reader.current_char))
      else
        Failure.new("unexpected character #{reader.current_char.inspect}", state)
      end
    end
  end

  def range(range)
    RangeParser.new(range)
  end

  class ValueParser(T) < Parser(T)
    def initialize(@value : T)
    end

    def run(state : State)
      Success.new(@value, state)
    end
  end

  def value(v)
    ValueParser.new(v)
  end

  class PositionParser < Parser(Position)
    def run(state : State)
      Success.new(state.position, state)
    end
  end

  def position
    PositionParser.new
  end

  class LazyParser(T) < Parser(T)
    @parser : Parser(T)?

    def initialize(@proc : Proc(Parser(T)))
    end

    def parser
      @parser ||= @proc.call
    end

    def run(state : State)
      parser.run(state)
    end
  end

  def lazy(proc)
    LazyParser.new(proc)
  end

  def lazy(type : T.class, &block : Proc(Parser(T))) forall T
    LazyParser.new(block)
  end
end
