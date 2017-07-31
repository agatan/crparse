require "../parser"

module Crparse::Parsers
  {% for index in 1..32 %}
    {% types = (0..index).map { |i| "T#{i}".id } %}
    {% parsers = (0..index).map { |i| "t#{i}".id } %}
    {% instance_parsers = (0..index).map { |i| "@t#{i}".id } %}
    {% instance_parsers_with_types = (0..index).map { |i| "@t#{i} : Parser(T#{i})".id } %}
    {% attributes = (0..index).map { |i| "attr#{i}".id } %}

    class {{ "Seq#{index+1}Parser".id }}({{ *types }}) < Parser({ {{ *types }} })
      def initialize({{ *instance_parsers_with_types }})
      end

      def run(state : State)
        {% for attr, i in attributes %}
          {{ attr }} : {{ types[i] }}
        {% end %}

        {% for p, i in instance_parsers %}
          case result = {{ p }}.run(state)
          when Success
            state = result.state
            {{ attributes[i] }} = result.attribute
          else
            return result
          end
        {% end %}

        Success.new({ {{ *attributes }} }, state)
      end
    end

    def seq({{ *parsers }})
      {{ "Seq#{index+1}Parser".id }}.new({{ *parsers }})
    end
  {% end %}
end
