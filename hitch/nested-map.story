Nested mapping validation:
  based on: strictyaml
  description: |
    Mappings can be nested within one another, which
    will be parsed as a dict within a dict.
  given:
    setup: |
      from strictyaml import Map, Int, load
      from ensure import Ensure

      schema = Map({"a": Map({"x": Int(), "y": Int()}), "b": Int(), "c": Int()})
  variations:
    Valid nested mapping:
      given:
        yaml_snippet: |
          a:
            x: 9
            y: 8
          b: 2
          c: 3
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": {"x": 9, "y": 8}, "b": 2, "c": 3})


    Invalid nested mapping:
      given:
        yaml_snippet: |
          a:
            x: 9
            z: 8
          b: 2
          d: 3
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              unexpected key not in schema 'z'
                in "<unicode string>", line 3, column 1:
                    z: '8'
                  ^ (line: 3)

    No nested mapping where expected:
      given:
        yaml_snippet: |
          a: 11
          b: 2
          d: 3
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a mapping
              found an arbitrary integer
                in "<unicode string>", line 1, column 1:
                  a: '11'
                   ^ (line: 1)
    Modify nested map:
      given:
        yaml_snippet: |
          a:
            x: 9
            y:
            - 1
            - 2
            - 3
          b: 2
          c: 3
        setup: |
          from strictyaml import Map, Int, load, Seq
          from collections import OrderedDict

          schema = Map({"a": Map({"x": Int(), "y": Seq(Int())}), "b": Int(), "c": Int()})

          yaml = load(yaml_snippet, schema)

          # Non-ordered dict would also work, but would yield an indeterminate order of keys
          yaml['a'] = OrderedDict([("x", 5), ("y", [4, 5, 6])])
          yaml['a']['x'] = 99
      steps:
      - Run:
          code: print(yaml.as_yaml())
          will output: |-
            a:
              x: 99
              y:
              - 4
              - 5
              - 6
            b: 2
            c: 3

