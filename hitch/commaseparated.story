Parsing comma separated items (CommaSeparated):
  docs: scalar/comma-separated
  based on: strictyaml
  description: |
    Comma-separated values can be validated and parsed
    using the CommaSeparated validator.

    Note that the space following the commas is stripped by
    default when parsed.
  given:
    setup: |
      from strictyaml import CommaSeparated, Int, Str, Map, load, as_document
      from ensure import Ensure

      int_schema = Map({"a": CommaSeparated(Int())})

      str_schema = Map({"a": CommaSeparated(Str())})
  variations:
    Parse as int:
      given:
        yaml_snippet: |
          a: 1, 2, 3
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, int_schema)).equals({"a": [1, 2, 3]})

    Parse as string:
      given:
        yaml_snippet: |
          a: 1, 2, 3
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, str_schema)).equals({"a": ["1", "2", "3"]})

    Invalid int comma separated sequence:
      given:
        yaml_snippet: |
          a: 1, x, 3
      steps:
      - Run:
          code: load(yaml_snippet, int_schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
                in "<unicode string>", line 2, column 1:
                  
                  ^ (line: 2)
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: 1, x, 3
                   ^ (line: 1)

    Serialize to comma separated sequence:
      steps:
      - Run:
          code: |
            print(as_document({"a": [1, 2, 3]}, int_schema).as_yaml())
          will output: 'a: 1, 2, 3'
