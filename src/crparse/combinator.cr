require "./result"
require "./parser"

module Crparse
  class MapParser(T, U) < Parser(U)
    def initialize(@parser : Parser(T), &@block : T -> U)
    end

    def run(state : State) : Success(U) | Failure
      case res = @parser.run(state)
      when Success
        res.map(&@block)
      else
        res
      end
    end
  end

  class AndParser(T, U) < Parser(Tuple(T, U))
    def initialize(@first : Parser(T), @second : Parser(U))
    end

    def run(state : State) : Success({T, U}) | Failure
      res = @first.run(state)
      case res
      when Success
        case snd = @second.run(res.state)
        when Success
          snd.map { |snd| {res.attribute, snd} }
        else
          snd
        end
      else
        res
      end
    end
  end

  class OrParser(T, U) < Parser(T | U)
    def initialize(@first : Parser(T), @second : Parser(U))
    end

    def run(state : State) : Success(T | U) | Failure
      res = @first.run(state)
      case res
      when Success
        res
      else
        @second.run(state)
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

    def +(r)
      and(r)
    end

    def <<(r)
      AndParser.new(self, r).map { |attr| attr[0] }
    end

    def >>(r)
      AndParser.new(self, r).map { |attr| attr[1] }
    end

    def |(r)
      OrParser.new(self, r)
    end
  end
end
