Validating optional keys in mappings (Map):
  docs: compound/optional-keys
  based on: strictyaml
  description: |
    Not every key in a YAML mapping will be required. If
    you use the "Optional('key')" validator with YAML,
    you can signal that a key/value pair is not required.
  given:
    setup: |
      from strictyaml import Map, Int, Str, Bool, Optional, load
      from ensure import Ensure

      schema = Map({"a": Int(), Optional("b"): Bool(), })
  variations:
    Valid example 1:
      given:
        yaml_snippet: |
          a: 1
          b: yes
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": True})

    Valid example 2:
      given:
        yaml_snippet: |
          a: 1
          b: no
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": False})

    Valid example missing key:
      given:
        yaml_snippet: 'a: 1'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1})

    Invalid 1:
      given:
        yaml_snippet: |
          a: 1
          b: 2
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a boolean value (one of "yes", "true", "on", "1", "y", "no", "false", "off", "0", "n")
              found an arbitrary integer
                in "<unicode string>", line 2, column 1:
                  b: '2'
                  ^ (line: 2)
    Invalid 2:
      given:
        yaml_snippet: |
          a: 1
          b: yes
          c: 3
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              unexpected key not in schema 'c'
                in "<unicode string>", line 3, column 1:
                  c: '3'
                  ^ (line: 3)


Nested optional validation:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import Map, Int, Str, Bool, Optional, load
      from ensure import Ensure

      schema = Map({"a": Int(), Optional("b"): Map({Optional("x"): Str(), Optional("y"): Str()})})
  variations:
    Valid 1:
      given:
        yaml_snippet: 'a: 1'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1})

    Valid 2:
      given:
        yaml_snippet: |
          a: 1
          b:
            x: y
            y: z
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals(
                {"a": 1, "b": {"x": "y", "y": "z"}}
            )
