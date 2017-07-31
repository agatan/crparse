require "./result"
require "./parser"

module Crparse
  class MapParser(T, U) < Parser(T)
    def initialize(@parser : Parser(T), &@block : T -> U)
    end

    def run(state : State)
      case res = @parser.run(state)
      when Success
        res.map(&@block)
      else
        res
      end
    end
  end

  class AndParser(T, U) < Parser(Tuple(T, U))
    def initialize(@first : T, @second : U)
    end

    def run(state : State)
      res = @first.run(state)
      case res
      when Success
        case snd = @second.run(res.state)
        when Success
          snd.map { |snd| { res.attribute, snd } }
        else
          snd
        end
      else
        res
      end
    end
  end

  class Parser(T)
    def and(r)
      AndParser.new(self, r)
    end

    def map(&block : T -> _)
      # block.call "foo"
      MapParser.new(self, &block)
    end
  end
end
