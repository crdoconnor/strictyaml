Fixed length sequences (FixedSeq):
  docs: compound/fixed-length-sequences
  based on: strictyaml
  description: |
    Sequences of fixed length can be validated with a series
    of different (or the same) types.
  given:
    setup: |
      from strictyaml import FixedSeq, Str, Map, Int, Float, YAMLValidationError, load
      from ensure import Ensure

      schema = FixedSeq([Int(), Map({"x": Str()}), Float()])
  variations:
    Equivalent list:
      given:
        yaml_snippet: |
          - 1
          - x: 5
          - 2.5
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals([1, {"x": "5"}, 2.5, ])

    Invalid list 1:
      given:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a sequence of 3 elements
                in "<unicode string>", line 1, column 1:
                  a: '1'
                   ^ (line: 1)
              found a mapping
                in "<unicode string>", line 3, column 1:
                  c: '3'
                  ^ (line: 3)

    Invalid list 2:
      given:
        yaml_snippet: |
          - 2
          - a
          - a:
            - 1
            - 2
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a mapping
              found arbitrary text
                in "<unicode string>", line 2, column 1:
                  - a
                  ^ (line: 2)

    Invalid list 3:
      given:
        yaml_snippet: |
          - 1
          - a
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a sequence of 3 elements
                in "<unicode string>", line 1, column 1:
                  - '1'
                   ^ (line: 1)
              found a sequence of 2 elements
                in "<unicode string>", line 2, column 1:
                  - a
                  ^ (line: 2)
