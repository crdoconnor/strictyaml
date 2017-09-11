Nested mapping validation:
  based on: strictyaml
  importance: 4
  description: |
    Mappings can be nested within one another, which
    will be parsed as a dict within a dict.
  preconditions:
    setup: |
      from strictyaml import Map, Int, load

      schema = Map({"a": Map({"x": Int(), "y": Int()}), "b": Int(), "c": Int()})
  variations:
    Valid nested mapping:
      preconditions:
        yaml_snippet: |
          a:
            x: 9
            y: 8
          b: 2
          c: 3
        code: load(yaml_snippet, schema)
      scenario:
      - Should be equal to: |
          {"a": {"x": 9, "y": 8}, "b": 2, "c": 3}

    Invalid nested mapping:
      preconditions:
        yaml_snippet: |
          a:
            x: 9
            z: 8
          b: 2
          d: 3
        code: load(yaml_snippet, schema)
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            while parsing a mapping
            unexpected key not in schema 'z'
              in "<unicode string>", line 3, column 1:
                  z: '8'
                ^ (line: 3)

    No nested mapping where expected:
      preconditions:
        yaml_snippet: |
          a: 11
          b: 2
          d: 3
        code: load(yaml_snippet, schema)
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a mapping
            found non-mapping
              in "<unicode string>", line 1, column 1:
                a: '11'
                 ^ (line: 1)
