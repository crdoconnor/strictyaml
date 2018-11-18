Enumerated scalars (Enum):
  docs: scalar/enum
  based on: strictyaml
  description: |
    StrictYAML allows you to ensure that a scalar
    value can only be one of a set number of items.

    It will throw an exception if any strings not
    in the list are found.
  given:
    setup: |
      from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load
      from collections import OrderedDict
      from ensure import Ensure

      schema = Map({"a": Enum(["A", "B", "C"])})
  variations:
    Valid because it contains 'A':
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema)).equals({"a": "A"})

    Get .data from enum:
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run: |
          assert isinstance(load(yaml_snippet, schema)['a'].data, str)

    Valid because it contains 'B':
      given:
        yaml_snippet: 'a: B'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "B"})

    Valid because it contains 'C':
      given:
        yaml_snippet: 'a: C'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": "C"})

    Invalid because D is not in enum:
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

    Invalid because blank string is not in enum:
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

    Successful serialization:
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            yaml['a'] = "B"
            print(yaml.as_yaml())
          will output: 'a: B'

    Invalid serialization:
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            yaml['a'] = "D"
            print(yaml.as_yaml())
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: "Got 'D' when  expecting one of: A, B, C"
