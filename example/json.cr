require "../src/crparse"

module JSONParser
  alias Result = Nil | Float64 | Array(Result)

  extend self

  include Crparse::Parsers

  WS = (char(' ') | char('\n') | char('\t') | char('\r')).many

  BEGIN_ARRAY     = WS >> char('[') << WS
  END_ARRAY       = WS >> char(']') << WS
  BEGIN_OBJECT    = WS >> char('{') << WS
  END_OBJECT      = WS >> char('}') << WS
  NAME_SEPARATOR  = WS >> char(':') << WS
  VALUE_SEPARATOR = WS >> char(',') << WS

  DIGIT    = range('0'..'9')
  DIGIT1_9 = range('1'..'9')
  E        = char('e') | char('E')
  EXP      = seq(E, (char('+') | char('-')).option, DIGIT.many1).map { |(e, op, n)| "#{e}#{op}#{n.join}" }
  FRAC     = char('.').and(DIGIT.many1).map { |(dot, n)| "#{dot}#{n.join}" }
  INT      = char('0').map(&.to_s) | (range('1'..'9') + range('0'..'9').many1).map { |(hd, tl)| "#{hd}#{tl.join}" }
  NUMBER   = seq(char('-').option, INT, FRAC.option, EXP.option).map do |(op, base, frac, exp)|
    "#{op}#{base}#{frac}#{exp}".to_f
  end

  NULL  = string("null")
  FALSE = string("false")
  TRUE  = string("true")

  HEXDIG_CHAR = (DIGIT | range('a'..'f') | range('A'..'F')).count(4).map { |ds| ds.join.to_i(16).chr }
  UNESCAPED   = range('\u{20}'..'\u{21}') | range('\u{23}'..'\u{5B}') | range('\u{5D}'..'\u{10FFFF}')
  ESCAPED = char('\\') >> (
    char('"') |
    char('\\') |
    char('/') |
    char('b').map { '\b' } |
    char('f').map { '\f' } |
    char('n').map { '\n' } |
    char('r').map { '\r' } |
    char('t').map { '\t' } |
    char('u') >> HEXDIG_CHAR |
    fail(Char, "invalid escape sequence")
  )
  CHAR = UNESCAPED | ESCAPED
  STRING = char('"') >> CHAR.many.map(&.join) << char('"')

  VALUE = NUMBER | STRING

  JSON = WS >> VALUE << WS << eof
end

input = STDIN.each_line.join
result = JSONParser::JSON.run(input).success!
p result.attribute
