Validating strings with regexes (Regex):
  docs: scalar/regular-expressions
  based on: strictyaml
  description: |
    StrictYAML can validate regular expressions and return a
    string. If the regular expression does not match, an
    exception is raised.
  given:
    setup: |
      from strictyaml import Regex, Map, load
      from ensure import Ensure

      schema = Map({"a": Regex(u"[1-4]"), "b": Regex(u"[5-9]")})
  variations:
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
