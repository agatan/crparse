require "./position"

module Crparse
  record State, input : String, position : Position do
    def initialize(input : String)
      initialize(input, Position.new)
    end

    def filename=(filename : String?)
      position.filename = filename
    end

    def byte_offset
      position.byte_offset
    end

    def reader
      Char::Reader.new(input, position.byte_offset)
    end

    def string
      input.byte_slice(position.byte_offset)
    end

    def shift(char : Char)
      State.new(input, position.shift(char))
    end

    def shift(str : String)
      State.new(input, str.each_char.reduce(position) { |loc, char| loc.shift(char) })
    end
  end

  class Success(T)
    getter attribute, state

    def initialize(@attribute : T, @state : State)
    end

    def map(&blk)
      attr = yield @attribute
      Success.new(attr, @state)
    end
  end

  class Failure
    getter message, state

    def initialize(@message : String, @state : State)
    end

    def position
      @state.position
    end

    def to_s(io)
      io << "#{position}: #{message}"
    end
  end
end
