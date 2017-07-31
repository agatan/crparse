require "./crparse/*"

module Crparse
  extend self

  def run(parser, input : String)
    state = State.new(input, 0)
    parser.run(state)
  end

  def run(parser, state : State)
    parser.run(state)
  end
end
