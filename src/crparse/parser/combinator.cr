require "../result"

module Crparse
  class MapParser(T, U)
    def initialize(@parser : WrapParser(T), &@block : T -> U)
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

  class AndParser(T, U)
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

  class WrapParser(T)
    def initialize(@parser : T)
    end

    def run(state)
      @parser.run state
    end

    def and(r)
      AndParser.new(@parser, r)
    end

    def map(&block)
      block.call "foo"
      # MapParser.new(self, &blk)
    end
  end
end
