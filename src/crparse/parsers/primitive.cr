require "../result"
require "../parser"

module Crparse::Parsers
  class FailParser < Parser(Nil)
    def initialize(@message : String)
    end

    def run(state : State)
      Failure.new(@message)
    end
  end

  class AnyParser < Parser(Char)
    def run(state : State)
      if state.input.bytesize > state.byte_offset
        ch = state.reader.current_char
        Success.new(ch, state.shift(ch))
      else
        Failure.new("expected any input")
      end
    end
  end

  def self.any
    AnyParser.new
  end

  class EOFParser < Parser(Nil)
    def run(state : State)
      if state.input.bytesize == state.byte_offset
        Success.new(nil, state)
      else
        Failure.new("expected EOF")
      end
    end
  end

  def self.eof
    EOFParser.new
  end

  class CharParser < Parser(Char)
    def initialize(@needle : Char)
    end

    def run(state : State)
      if state.reader.current_char == @needle
        Success.new(@needle, state.shift(@needle))
      else
        Failure.new("expected #{@needle.inspect}")
      end
    end
  end

  def self.char(ch)
    CharParser.new(ch)
  end

  class StringParser < Parser(String)
    def initialize(@needle : String)
    end

    def run(state : State)
      if state.string.starts_with?(@needle)
        Success.new(@needle, state.shift(@needle))
      else
        Failure.new("expected #{@needle.inspect}")
      end
    end
  end

  def self.string(str)
    StringParser.new(str)
  end
end
