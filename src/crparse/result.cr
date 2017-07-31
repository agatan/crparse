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

    def success!
      self
    end
  end

  class Failure < Exception
    getter message_without_position, state

    def initialize(@message_without_position : String, @state : State)
      super(@message_without_position)
    end

    def position
      @state.position
    end

    def message
      "#{position}: #{@message_without_position}"
    end

    def to_s(io)
      io << message
    end

    def success!
      raise self
    end
  end
end
