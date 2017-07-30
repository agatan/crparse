module Crparse
  record State, input : String, pos : Int32 do
    def reader
      Char::Reader.new(input, pos)
    end

    def string
      input.byte_slice(pos)
    end

    def +(offset : Int32)
      State.new(input, pos + offset)
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
