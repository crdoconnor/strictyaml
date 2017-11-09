Map Pattern:
  based on: strictyaml
  description: |
    When you do not wish to let the user define the key
    names in a mapping and and only specify what type the
    keys are, use a MapPattern.

    When you wish to specify the exact key name, use the
    'Map' validator instead.
  preconditions:
    setup: |
      from strictyaml import MapPattern, Int, Str, YAMLValidationError, load
      from ensure import Ensure

      schema = MapPattern(Str(), Int())

  variations:
    Equivalence 1:
      preconditions:
        yaml_snippet: |
          â: 1
          b: 2
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({u"â": 1, "b": 2})
    Equivalence 2:
      preconditions:
        yaml_snippet: |
          a: 1
          c: 3
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "c": 3})
    Equivalence 3:
      preconditions:
        yaml_snippet: |
          a: 1
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, })


    Invalid 1:
      preconditions:
        yaml_snippet: |
          b: b
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  b: b
                   ^ (line: 1)
    Invalid 2:
      preconditions:
        yaml_snippet: |
          a: a
          b: 2
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: a
                   ^ (line: 1)

    More than the maximum number of keys:
      preconditions:
        yaml_snippet: |
          â: 1
          b: 2
      scenario:
      - Run:
          code: load(yaml_snippet, MapPattern(Str(), Int(), maximum_keys=1))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
                in "<unicode string>", line 1, column 1:
                  "\xE2": '1'
                   ^ (line: 1)
              expected a maximum of 1 key, found 2.
                in "<unicode string>", line 2, column 1:
                  b: '2'
                  ^ (line: 2)

    Fewer than the minimum number of keys:
      preconditions:
        yaml_snippet: |
          â: 1
      scenario:
      - Run:
          code: load(yaml_snippet, MapPattern(Str(), Int(), minimum_keys=2))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              expected a minimum of 2 keys, found 1.
                in "<unicode string>", line 1, column 1:
                  "\xE2": '1'
                   ^ (line: 1)

    Invalid with non-ascii:
      preconditions:
        yaml_snippet: |
          a: 1
          b: yâs
          c: 3
      scenario:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 2, column 1:
                  b: "y\xE2s"
                  ^ (line: 2)
