Unique sequences:
  based on: strictyaml
  description: |
    UniqueSeq validates sequences which contain no duplicate
    values.
  scenario:
    - Code: |
        from strictyaml import UniqueSeq, Str, YAMLValidationError, load

        schema = UniqueSeq(Str())

    - Variable:
        name: valid_sequence
        value: |
          - A
          - B
          - C

    - Returns True: 'load(valid_sequence, schema) == ["A", "B", "C", ]'

    - Variable:
        name: invalid_sequence_1
        value: |
          - A
          - B
          - B

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          while parsing a sequence
            in "<unicode string>", line 1, column 1:
              - A
               ^ (line: 1)
          duplicate found
            in "<unicode string>", line 3, column 1:
              - B
              ^ (line: 3)

    - Variable:
        name: invalid_sequence_2
        value: |
          - 3
          - 3
          - 3

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          while parsing a sequence
            in "<unicode string>", line 1, column 1:
              - '3'
               ^ (line: 1)
          duplicate found
            in "<unicode string>", line 3, column 1:
              - '3'
              ^ (line: 3)

