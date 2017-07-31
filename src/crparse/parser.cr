require "./result"

module Crparse
  abstract class Parser(T)
    abstract def run(state : State) : Success(T) | Failure

    def run(input : String, filename : String? = nil)
      state = State.new(input)
      state.filename = filename
      run(state)
    end
  end
end
