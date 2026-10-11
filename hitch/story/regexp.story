Validating strings with regexes (Regex):
  docs: scalar/regular-expressions
  based on: strictyaml
  description: |
    StrictYAML can validate regular expressions and return a
    string. If the regular expression does not match, an
    exception is raised.
  given:
    setup: |
      from strictyaml import Regex, Map, load, as_document
      from collections import OrderedDict
      from ensure import Ensure
      import pytest
      from strictyaml.exceptions import YAMLValidationError, YAMLSerializationError

      schema = Map({"a": Regex(u"[1-4]"), "b": Regex(u"[5-9]")})
  variations:
    Alternatives reject trailing content when parsing:
      steps:
      - Run:
          code: |
            for value in ("dogtail", "dogcat", "cat tail"):
                with pytest.raises(YAMLValidationError):
                    load(value, Regex("dog|cat"))

    Alternatives reject trailing content when serializing:
      steps:
      - Run:
          code: |
            for value in ("dogtail", "dogcat", "cat tail"):
                with pytest.raises(YAMLSerializationError):
                    as_document(value, Regex("dog|cat"))

    Terminal newlines must match the expression too:
      steps:
      - Run:
          code: |
            for expression in ("dog", "dog$", "^dog$"):
                with pytest.raises(YAMLSerializationError):
                    as_document("dog\n", Regex(expression))

    Complete alternatives and inline flags still work:
      steps:
      - Run:
          code: |
            for value in ("dog", "cat", "DOG", "CAT"):
                Ensure(load(value, Regex("(?i)dog|cat")).data).equals(value)
                Ensure(as_document(value, Regex("(?i)dog|cat")).data).equals(value)

    Parsed correctly:
      given:
        yaml_snippet: |
          a: 1
          b: 5
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "1", "b": "5"})

    Non-matching:
      given:
        yaml_snippet: |
          a: 5
          b: 5
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting string matching [1-4]
              found non-matching string
                in "<unicode string>", line 1, column 1:
                  a: '5'
                   ^ (line: 1)

    Non-matching suffix:
      given:
        yaml_snippet: |
          a: 1 Hello
          b: 5
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting string matching [1-4]
              found non-matching string
                in "<unicode string>", line 1, column 1:
                  a: 1 Hello
                   ^ (line: 1)

    Serialized successfully:
      steps:
      - Run:
          code: |
            print(as_document(OrderedDict([("a", "1"), ("b", "5")]), schema).as_yaml())
          will output: |-
            a: 1
            b: 5

    Serialization failure non matching regex:
      steps:
      - Run:
          code: |
            as_document(OrderedDict([("a", "x"), ("b", "5")]), schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: when expecting string matching [1-4] found 'x'

    Serialization failure not a string:
      steps:
      - Run:
          code: |
            as_document(OrderedDict([("a", 1), ("b", "5")]), schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: when expecting string matching [1-4] got '1' of type int.
