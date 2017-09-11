Fixed length sequences (FixedSeq):
  based on: strictyaml
  description: |
    Sequences of fixed length can be validated with a series
    of different (or the same) types.
  preconditions:
    setup: |
      from strictyaml import FixedSeq, Str, Int, Float, YAMLValidationError, load

      schema = FixedSeq([Int(), Str(), Float()])
    code: |
      load(yaml_snippet, schema)
  variations:
    Equivalent list:
      preconditions:
        yaml_snippet: |
          - 1
          - a
          - 2.5
      scenario:
      - Should be equal to: '[1, "a", 2.5, ]'

    Invalid list 1:
      preconditions:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a sequence of 3 elements
              in "<unicode string>", line 1, column 1:
                a: '1'
                 ^ (line: 1)
            found non-sequence
              in "<unicode string>", line 3, column 1:
                c: '3'
                ^ (line: 3)

    Invalid list 2:
      preconditions:
        yaml_snippet: |
          - 2
          - a
          - a:
            - 1
            - 2
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a float
              in "<unicode string>", line 3, column 1:
                - a:
                ^ (line: 3)
            found mapping/sequence
              in "<unicode string>", line 5, column 1:
                  - '2'
                ^ (line: 5)

    Invalid list 3:
      preconditions:
        yaml_snippet: |
          - 1
          - a
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a sequence of 3 elements
              in "<unicode string>", line 1, column 1:
                - '1'
                 ^ (line: 1)
            found a sequence of 2 elements
              in "<unicode string>", line 2, column 1:
                - a
                ^ (line: 2)
