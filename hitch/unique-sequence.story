Unique sequences:
  based on: strictyaml
  description: |
    UniqueSeq validates sequences which contain no duplicate
    values.
  preconditions:
    files:
      valid_sequence.yaml: |
        - A
        - B
        - C
      invalid_sequence_1.yaml: |
        - A
        - B
        - B
      invalid_sequence_2.yaml: |
        - 3
        - 3
        - 3
  scenario:
    - Code: |
        from strictyaml import UniqueSeq, Str, YAMLValidationError, load

        schema = UniqueSeq(Str())

    - Returns True: 'load(valid_sequence, schema) == ["A", "B", "C", ]'

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

