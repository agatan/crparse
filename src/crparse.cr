require "./crparse/*"

module Crparse
  extend self

  def run(parser, input : String)
    state = State.new(input)
    parser.run(state)
  end

  def run(parser, state : State)
    parser.run(state)
  end
end
