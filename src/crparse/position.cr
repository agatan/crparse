module Crparse
  struct Position
    property? filename : String?
    property byte_offset : Int32, line : Int32, column : Int32

    def initialize
      @byte_offset = 0
      @line = 1
      @column = 1
    end

    def initialize(@filename, @byte_offset, @line, @column)
    end

    def shift(char)
      if char == '\n'
        Position.new(@filename, @byte_offset + char.bytesize, @line + 1, 1)
      else
        Position.new(@filename, @byte_offset + char.bytesize, @line, @column + 1)
      end
    end

    def to_s(io)
      if f = @filename
        io << "#{f}:#{line}:#{column}"
      else
        io << "#{line}:#{column}"
      end
    end
  end
end
