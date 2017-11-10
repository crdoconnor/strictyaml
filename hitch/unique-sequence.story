Unique sequences:
  based on: strictyaml
  description: |
    UniqueSeq validates sequences which contain no duplicate
    values.
  given:
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
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals(["A", "B", "C", ])

    One dupe:
      given:
        yaml_snippet: |
          - A
          - B
          - B
      steps:
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
      given:
        yaml_snippet: |
          - 3
          - 3
          - 3
      steps:
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
