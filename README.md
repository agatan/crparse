# crparse

Parser Combinator library for Crystal.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crparse:
    github: agatan/crparse
```

## Usage

```crystal
require "crparse"

module MyParser
  extern self
  include Crparse::Parsers

  def integer
    range('0'..'9').many1.map(&.join.to_i)
  end
end

p MyParser.integer.run("123").success!.attribute # => 123
```


## Contributing

1. Fork it ( https://github.com/agatan/crparse/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [agatan](https://github.com/agatan) Naomichi Agata - creator, maintainer
