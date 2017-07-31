require "./spec_helper"

describe Crparse::AnyParser do
  it "success to parse any character" do
    parser = Crparse.any
    result = Crparse.run(parser, "abc").as(Crparse::Success)
    result.attribute.should eq 'a'
    result.state.string.should eq "bc"
  end

  it "fails if no input given" do
    parser = Crparse.any
    Crparse.run(parser, "").as(Crparse::Failure)
  end
end

describe Crparse::EOFParser do
  it "successes if the given input is empty" do
    parser = Crparse.eof
    Crparse.run(parser, "").as(Crparse::Success)
  end

  it "fails if the given input is not empty" do
    parser = Crparse.eof
    Crparse.run(parser, "abc").as(Crparse::Failure)
  end
end

describe Crparse::CharParser do
  it "success to parse string" do
    parser = Crparse.char('a')
    result = Crparse.run(parser, "abcdef").as(Crparse::Success)
    result.attribute.should eq 'a'
    result.state.string.should eq "bcdef"
  end
end

describe Crparse::StringParser do
  it "success to parse string" do
    parser = Crparse.string("abc")
    result = Crparse.run(parser, "abcdef").as(Crparse::Success)
    result.attribute.should eq "abc"
    result.state.string.should eq "def"
  end
end

describe Crparse::AndParser do
  it "parses consequently" do
    parser = Crparse.string("abc").and(Crparse.string("def"))
    result = Crparse.run(parser, "abcdef").as(Crparse::Success)
    result.attribute.should eq({"abc", "def"})
    result.state.string.should eq ""
  end
end

describe Crparse::MapParser do
  it "maps parser result" do
    parser = Crparse.string("abc").map { |s| "#{s}!" }
    result = Crparse.run(parser, "abcdef").as(Crparse::Success)
    result.attribute.should eq "abc!"
    result.state.string.should eq "def"
  end
end

describe Crparse::Parser do
  describe "#+" do
    it "combine two parsers" do
      parser = Crparse.string("abc") + Crparse.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq ({"abc", "def"})
      result.state.string.should eq ""
    end
  end

  describe "#<<" do
    it "discards right hand side attribute" do
      parser = Crparse.string("abc") << Crparse.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "abc"
      result.state.string.should eq ""
    end
  end

  describe "#>>" do
    it "discards right hand side attribute" do
      parser = Crparse.string("abc") >> Crparse.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "def"
      result.state.string.should eq ""
    end
  end

  describe "#|" do
    it "works as `or` parser" do
      parser = Crparse.string("abc") | Crparse.string("def")
      result = parser.run("abcdef").as(Crparse::Success)
      result.attribute.should eq "abc"
      result.state.string.should eq "def"
      result = parser.run("defghi").as(Crparse::Success)
      result.attribute.should eq "def"
      result.state.string.should eq "ghi"
    end
  end
end
