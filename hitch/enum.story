Enum (enum validation):
  based on: strictyaml
  description: |
    StrictYAML allows you to ensure that a scalar
    value can only be one of a set number of items.

    It will throw an exception if any strings not
    in the list are found.
  given:
    setup: |
      from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load
      from ensure import Ensure

      schema = Map({"a": Enum(["A", "B", "C"])})
    code:
  variations:
    Valid A:
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "A"})

    Valid B:
      given:
        yaml_snippet: 'a: B'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "B"})

    Valid C:
      given:
        yaml_snippet: 'a: C'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "C"})

    Invalid not in enum:
      given:
        yaml_snippet: 'a: D'
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting one of: A, B, C
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: D
                   ^ (line: 1)
    Invalid blank string:
      given:
        yaml_snippet: 'a:'
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting one of: A, B, C
              found a blank string
                in "<unicode string>", line 1, column 1:
                  a: ''
                   ^ (line: 1)
