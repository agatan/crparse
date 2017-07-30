require "../result"

module Crparse
  class FailParser
    def initialize(@message : String)
    end

    def run(state : State)
      Failure.new(@message)
    end
  end

  class AnyParser
    def run(state : State)
      if state.input.bytesize > state.pos
        ch = state.reader.current_char
        Success.new(ch, state + ch.bytesize)
      else
        Failure.new("expected any input")
      end
    end
  end

  class EOFParser
    def run(state : State)
      if state.input.bytesize == state.pos
        Success.new(nil, state)
      else
        Failure.new("expected EOF")
      end
    end
  end

  class CharParser
    def initialize(@needle : Char)
    end

    def run(state : State)
      if state.reader.current_char == @needle
        Success.new(@needle, state + @needle.bytesize)
      else
        Failure.new("expected #{@needle.inspect}")
      end
    end
  end

  class StringParser
    def initialize(@needle : String)
    end

    def run(state : State)
      if state.string.starts_with?(@needle)
        Success.new(@needle, state + @needle.bytesize)
      else
        Failure.new("expected #{@needle.inspect}")
      end
    end
  end
end
