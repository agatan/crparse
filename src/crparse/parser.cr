require "./result"

module Crparse
  abstract class Parser(T)
    abstract def run(state : State) : Success(T) | Failure

    def run(input : String)
      state = State.new(input, 0)
      run(state)
    end
  end
end
