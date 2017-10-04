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
      from strictyaml import UniqueSeq, Str, load
      from ensure import Ensure

      schema = UniqueSeq(Str())
  variations:
    Valid:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals(["A", "B", "C", ])

    One dupe:
      preconditions:
        yaml_snippet: |
          - A
          - B
          - B
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a sequence
                in "<unicode string>", line 1, column 1:
                  - A
                   ^ (line: 1)
              duplicate found
                in "<unicode string>", line 3, column 1:
                  - B
                  ^ (line: 3)
    All dupes:
      preconditions:
        yaml_snippet: |
          - 3
          - 3
          - 3
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a sequence
                in "<unicode string>", line 1, column 1:
                  - '3'
                   ^ (line: 1)
              duplicate found
                in "<unicode string>", line 3, column 1:
                  - '3'
                  ^ (line: 3)
