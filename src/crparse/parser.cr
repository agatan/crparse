require "./result"

module Crparse
  abstract class Parser(T)
    abstract def run(state : State) : Result(T)

    def run(input : String)
      state = State.new(input, 0)
      parser.run(state)
    end
  end
end
