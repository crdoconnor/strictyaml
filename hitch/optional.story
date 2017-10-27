Optional validation:
  based on: strictyaml
  description: |
    Not every key in a YAML mapping will be required. If
    you use the "Optional('key')" validator with YAML,
    you can signal that a key/value pair is not required.
  preconditions:
    setup: |
      from strictyaml import Map, Int, Str, Bool, Optional, load
      from ensure import Ensure

      schema = Map({"a": Int(), Optional("b"): Bool(), })
    code:
  variations:
    Valid example 1:
      preconditions:
        yaml_snippet: |
          a: 1
          b: yes
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": True})

    Valid example 2:
      preconditions:
        yaml_snippet: |
          a: 1
          b: no
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": False})

    Valid example missing key:
      preconditions:
        yaml_snippet: 'a: 1'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1})

    Invalid 1:
      preconditions:
        yaml_snippet: |
          a: 1
          b: 2
      scenario:
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
      preconditions:
        yaml_snippet: |
          a: 1
          b: yes
          c: 3
      scenario:
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
  preconditions:
    setup: |
      from strictyaml import Map, Int, Str, Bool, Optional, load
      from ensure import Ensure

      schema = Map({"a": Int(), Optional("b"): Map({Optional("x"): Str(), Optional("y"): Str()})})
  variations:
    Valid 1:
      preconditions:
        yaml_snippet: 'a: 1'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1})

    Valid 2:
      preconditions:
        yaml_snippet: |
          a: 1
          b:
            x: y
            y: z
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals(
                {"a": 1, "b": {"x": "y", "y": "z"}}
            )
