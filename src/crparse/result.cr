require "./location"

module Crparse
  record State, input : String, location : Location do
    def initialize(input : String)
      initialize(input, Location.new)
    end

    def filename=(filename : String?)
      location.filename = filename
    end

    def byte_offset
      location.byte_offset
    end

    def reader
      Char::Reader.new(input, location.byte_offset)
    end

    def string
      input.byte_slice(location.byte_offset)
    end

    def shift(char : Char)
      State.new(input, location.shift(char))
    end

    def shift(str : String)
      State.new(input, str.each_char.reduce(location) { |loc, char| loc.shift(char) })
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
    getter message

    def initialize(@message : String)
    end
  end
end
