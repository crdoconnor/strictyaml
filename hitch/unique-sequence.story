Unique sequences:
  based on: strictyaml
  description: |
    UniqueSeq validates sequences which contain no duplicate
    values.
  preconditions:
    yaml_snippet: |
      - A
      - B
      - C
    setup: |
      from strictyaml import UniqueSeq, Str, YAMLValidationError, load

      schema = UniqueSeq(Str())


Unique sequence valid:
  based on: Unique sequences
  preconditions:
    code: load(yaml_snippet, schema)
  scenario:
    - Should be equal to: ' ["A", "B", "C", ]'

Unique sequence invalid:
  based on: Unique sequences
  preconditions:
    yaml_snippet: |
      - A
      - B
      - B
    code: |
      load(yaml_snippet, schema)
  scenario:
    - Raises Exception: |
        while parsing a sequence
          in "<unicode string>", line 1, column 1:
            - A
             ^ (line: 1)
        duplicate found
          in "<unicode string>", line 3, column 1:
            - B
            ^ (line: 3)

Unique sequence all invalid:
  based on: Unique sequences
  preconditions:
    yaml_snippet: |
      - 3
      - 3
      - 3
    code: |
      load(yaml_snippet, schema)
  scenario:
    - Raises Exception: |
        while parsing a sequence
          in "<unicode string>", line 1, column 1:
            - '3'
             ^ (line: 1)
        duplicate found
          in "<unicode string>", line 3, column 1:
            - '3'
            ^ (line: 3)

