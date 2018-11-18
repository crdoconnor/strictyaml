Labeling exceptions:
  docs: howto/label-exceptions
  based on: strictyaml
  description: |
    When raising exceptions, you can add a label that will replace
    <unicode string> with whatever you want.
  given:
    setup: |
      from strictyaml import Map, Int, load, YAMLValidationError
    yaml_snippet: |
      a: 1
      b:
        - 1
        - 2
  variations:
    Label myfilename:
      steps:
      - Run:
          code: |
            load(yaml_snippet, Map({"a": Int(), "b": Map({"x": Int(), "y": Int()})}), label="myfilename")
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a mapping
                in "myfilename", line 2, column 1:
                  b:
                  ^ (line: 2)
              found a sequence
                in "myfilename", line 4, column 1:
                  - '2'
                  ^ (line: 4)
