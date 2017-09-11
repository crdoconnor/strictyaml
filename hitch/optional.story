Optional validation:
  based on: strictyaml
  description: |
    Not every key in a YAML mapping will be required. If
    you use the "Optional('key')" validator with YAML,
    you can signal that a key/value pair is not required.
  preconditions:
    setup: |
      from strictyaml import Map, Int, Str, Bool, Optional, load

      schema = Map({"a": Int(), Optional("b"): Bool(), })
    code: load(yaml_snippet, schema)
  variations:
    Valid example 1:
      preconditions:
        yaml_snippet: |
          a: 1
          b: yes
      scenario:
      - Should be equal to: '{"a": 1, "b": True}'

    Valid example 2:
      preconditions:
        yaml_snippet: |
          a: 1
          b: no
      scenario:
      - Should be equal to: '{"a": 1, "b": False}'

    Valid example missing key:
      preconditions:
        yaml_snippet: 'a: 1'
      scenario:
      - Should be equal to: '{"a": 1}'

    Invalid 1:
      preconditions:
        yaml_snippet: |
          a: 1
          b: 2
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a boolean value (one of "yes", "true", "on", "1", "y", "no", "false", "off", "0", "n")
            found non-boolean
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
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
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

      schema = Map({"a": Int(), Optional("b"): Map({Optional("x"): Str(), Optional("y"): Str()})})
    code: load(yaml_snippet, schema)
  variations:
    Valid 1:
      preconditions:
        yaml_snippet: 'a: 1'
      scenario:
      - Should be equal to: '{"a": 1}'
    Valid 2:
      preconditions:
        yaml_snippet: |
          a: 1
          b:
            x: y
            y: z
      scenario:
      - Should be equal to: '{"a": 1, "b": {"x": "y", "y": "z"}}'
