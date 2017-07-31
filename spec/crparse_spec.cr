require "./spec_helper"

Parsers = Crparse::Parsers

describe Crparse::Parsers do
  describe "fail" do
    it "always fails with the given message" do
      result = Parsers.fail(Char, "failure message").run("").as(Crparse::Failure)
      result.message.should eq "failure message"
    end
  end
  describe "any" do
    it "success to parse any character" do
      parser = Parsers.any
      result = Crparse.run(parser, "abc").as(Crparse::Success)
      result.attribute.should eq 'a'
      result.state.string.should eq "bc"
    end

    it "fails if no input given" do
      parser = Parsers.any
      Crparse.run(parser, "").as(Crparse::Failure)
    end
  end

  describe "eof" do
    it "successes if the given input is empty" do
      parser = Parsers.eof
      Crparse.run(parser, "").as(Crparse::Success)
    end

    it "fails if the given input is not empty" do
      parser = Parsers.eof
      Crparse.run(parser, "abc").as(Crparse::Failure)
    end
  end

  describe "char" do
    it "success to parse string" do
      parser = Parsers.char('a')
      result = Crparse.run(parser, "abcdef").as(Crparse::Success)
      result.attribute.should eq 'a'
      result.state.string.should eq "bcdef"
    end
  end

  describe "string" do
    it "success to parse string" do
      parser = Parsers.string("abc")
      result = Crparse.run(parser, "abcdef").as(Crparse::Success)
      result.attribute.should eq "abc"
      result.state.string.should eq "def"
    end
  end

  describe "range" do
    it "works with digit range" do
      result = Parsers.range('0'..'9').run("123").as(Crparse::Success)
      result.attribute.should eq '1'
      result.state.string.should eq "23"
    end
  end

  describe "seq" do
    it "parses 3 parsers and produce a tuple of 3 attributes" do
      parser = Parsers.seq(Parsers.char('a'), Parsers.char('b').map { 2 }, Parsers.char('c'))
      result = Crparse.run(parser, "abcdef").as(Crparse::Success)
      result.attribute.should eq ({'a', 2, 'c'})
      result.state.string.should eq "def"
    end
  end

  describe "value" do
    it "always returns the given value" do
      result = Parsers.value(1).run("abc").as(Crparse::Success)
      result.attribute.should eq 1
      result.state.string.should eq "abc"
    end
  end

  describe "position" do
    it "returns the position of current state" do
      result = Parsers.position.run("abc").as(Crparse::Success)
      result.attribute.should eq Crparse::Position.new
      result.state.string.should eq "abc"

      result = Parsers.seq(Parsers.string("abc"), Parsers.position).run("abcdef").as(Crparse::Success)
      result.attribute.should eq ({"abc", Crparse::Position.new(nil, 3, 1, 4)})
      result.state.string.should eq "def"
    end
  end
end

describe Crparse::Parser do
  describe "#+" do
    it "combine two parsers" do
      parser = Parsers.string("abc") + Parsers.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq ({"abc", "def"})
      result.state.string.should eq ""
    end
  end

  describe "#<<" do
    it "discards right hand side attribute" do
      parser = Parsers.string("abc") << Parsers.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "abc"
      result.state.string.should eq ""
    end
  end

  describe "#>>" do
    it "discards right hand side attribute" do
      parser = Parsers.string("abc") >> Parsers.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "def"
      result.state.string.should eq ""
    end
  end

  describe "#|" do
    it "works as `or` parser" do
      parser = Parsers.string("abc") | Parsers.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "abc"
      result.state.string.should eq "def"
      result = parser.run("defghi").as(Crparse::Success)
      result.attribute.should eq "def"
      result.state.string.should eq "ghi"
    end
  end

  describe "#option" do
    it "works to parse the attribute" do
      parser = Parsers.string("abc").option
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "abc"
      result.state.string.should eq "def"
    end

    it "works even if the attribute does not match the given input" do
      parser = Parsers.string("abc").option
      result = parser.run("def").as(Crparse::Success)
      result.attribute.should be_nil
      result.state.string.should eq "def"
    end
  end

  describe "#many" do
    it "parses sequence of given parser" do
      parser = Parsers.char('a').many
      result = parser.run("aaaa").as(Crparse::Success)
      result.attribute.should eq (['a'] * 4)
      result.state.string.should eq ""
      result = parser.run("").as(Crparse::Success)
      result.attribute.size.should eq 0
    end
  end

  describe "#many1" do
    it "parses sequence of given parser" do
      parser = Parsers.char('a').many1
      result = parser.run("aaaa").as(Crparse::Success)
      result.attribute.should eq (['a'] * 4)
      result.state.string.should eq ""
    end

    it "fails if no attributes match the parser" do
      parser = Parsers.char('a').many1
      parser.run("").as(Crparse::Failure)
    end
  end

  describe "#sep_by" do
    it "parses sequence of the given parser separated by the given separator" do
      parser = Parsers.char('a').sep_by(Parsers.char(','))
      case result = parser.run("a,a,a,a")
      when Crparse::Success
        result.attribute.should eq ['a']*4
      else
        raise "#{result.message} at #{result.state.position}"
      end
    end

    it "works even if the input is empty" do
      parser = Parsers.char('a').sep_by(Parsers.char(','))
      result = parser.run("").success!
      result.attribute.should eq [] of Char
    end
  end

  describe "#sep_by1" do
    it "parses sequence of the given parser separated by the given separator" do
      parser = Parsers.char('a').sep_by1(Parsers.char(','))
      case result = parser.run("a,a,a,a")
      when Crparse::Success
        result.attribute.should eq ['a']*4
      else
        raise "#{result.message} at #{result.state.position}"
      end
    end

    it "fails if the input is empty" do
      parser = Parsers.char('a').sep_by1(Parsers.char(','))
      parser.run("").should be_a Crparse::Failure
    end
  end
end
