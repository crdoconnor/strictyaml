Enum (enum validation):
  based on: strictyaml
  description: |
    StrictYAML allows you to ensure that a scalar
    value can only be one of a set number of items.

    It will throw an exception if any strings not
    in the list are found.
  preconditions:
    setup: |
      from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load
      from ensure import Ensure

      schema = Map({"a": Enum(["A", "B", "C"])})
    code:
  variations:
    Valid A:
      preconditions:
        yaml_snippet: 'a: A'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "A"})

    Valid B:
      preconditions:
        yaml_snippet: 'a: B'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "B"})

    Valid C:
      preconditions:
        yaml_snippet: 'a: C'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "C"})

    Invalid not in enum:
      preconditions:
        yaml_snippet: 'a: D'
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting one of: A, B, C
              found 'D'
                in "<unicode string>", line 1, column 1:
                  a: D
                   ^ (line: 1)
    Invalid blank string:
      preconditions:
        yaml_snippet: 'a:'
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting one of: A, B, C
              found ''
                in "<unicode string>", line 1, column 1:
                  a: ''
                   ^ (line: 1)
