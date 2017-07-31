require "../src/crparse"

module JSONParser
  alias Type = Nil | Float64 | String | Bool | Array(Type)

  extend self

  include Crparse::Parsers

  def self.ws
    (char(' ') | char('\n') | char('\t') | char('\r')).many
  end

  def self.begin_array
    ws >> char('[') << ws
  end

  def self.end_array
    ws >> char(']') << ws
  end

  def self.begin_object
    ws >> char('{') << ws
  end

  def self.end_object
    ws >> char('}') << ws
  end

  def self.name_separator
    ws >> char(':') << ws
  end

  def self.value_separator
    ws >> char(',') << ws
  end

  def self.digit
    range('0'..'9')
  end

  def self.digit1_9
    range('1'..'9')
  end

  def self.exp
    seq(char('e') | char('E'), (char('+') | char('-')).option, digit.many1).map { |(e, op, n)| "#{e}#{op}#{n.join}" }
  end

  def self.frac
    char('.').and(digit.many1).map { |(dot, n)| "#{dot}#{n.join}" }
  end

  def self.int
    char('0').map(&.to_s) | (range('1'..'9') + range('0'..'9').many).map { |(hd, tl)| "#{hd}#{tl.join}" }
  end

  def self.number
    seq(char('-').option, int, frac.option, exp.option).map do |(op, base, frac, exp)|
      "#{op}#{base}#{frac}#{exp}".to_f
    end
  end

  def self.null
    string("null").map { nil }
  end

  def self.bool
    string("false").map { false } | string("true").map { true }
  end

  def self.hexdig_char
    (digit | range('a'..'f') | range('A'..'F')).count(4).map { |ds| ds.join.to_i(16).chr }
  end

  def self.unescaped
    range('\u{20}'..'\u{21}') | range('\u{23}'..'\u{5B}') | range('\u{5D}'..'\u{10FFFF}')
  end

  def self.escaped
    char('\\') >> (
      char('"') |
      char('\\') |
      char('/') |
      char('b').map { '\b' } |
      char('f').map { '\f' } |
      char('n').map { '\n' } |
      char('r').map { '\r' } |
      char('t').map { '\t' } |
      char('u') >> hexdig_char |
      fail(Char, "invalid escape sequence")
    )
  end

  def self.char
    unescaped | escaped
  end

  def self.string
    char('"') >> char.many.map(&.join) << char('"')
  end

  def self.array
    begin_array >> lazy(->{ value.as(Crparse::Parser(Type)) }).sep_by(value_separator) << end_array
  end

  def self.value
    number | string | null | bool | array
  end

  def self.json
    ws >> value << ws << eof
  end
end

input = STDIN.each_line.join
result = JSONParser.json.run(input).success!
p result.attribute
