Fixed length sequences (FixedSeq):
  based on: strictyaml
  description: |
    Sequences of fixed length can be validated with a series
    of different (or the same) types.
  scenario:
    - Run command: |
        from strictyaml import FixedSeq, Str, Int, Float, YAMLValidationError, load

        schema = FixedSeq([Int(), Str(), Float()])

    - Variable:
        name: valid_sequence
        value: |
          - 1
          - a
          - 2.5

    - Returns True: load(valid_sequence, schema) == [1, "a", 2.5, ]

    - Variable:
        name: invalid_sequence_1
        value: |
          a: 1
          b: 2
          c: 3

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting a sequence of 3 elements
            in "<unicode string>", line 1, column 1:
              a: '1'
               ^ (line: 1)
          found non-sequence
            in "<unicode string>", line 3, column 1:
              c: '3'
              ^ (line: 3)

    - Variable:
        name: invalid_sequence_2
        value: |
          - 2
          - a
          - a:
            - 1
            - 2

    - Raises Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a float
            in "<unicode string>", line 3, column 1:
              - a:
              ^ (line: 3)
          found mapping/sequence
            in "<unicode string>", line 5, column 1:
                - '2'
              ^ (line: 5)

    - Variable:
        name: invalid_sequence_3
        value: |
          - 1
          - a

    - Raises Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          when expecting a sequence of 3 elements
            in "<unicode string>", line 1, column 1:
              - '1'
               ^ (line: 1)
          found a sequence of 2 elements
            in "<unicode string>", line 2, column 1:
              - a
              ^ (line: 2)

