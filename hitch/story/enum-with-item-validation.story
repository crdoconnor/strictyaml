Enum with item validation:
  docs: compound/map-pattern
  based on: strictyaml
  description: |
    See also: enum validation.

    Your enums can be a transformed string or something other than a string
    if you use an item validator.
  given:
    setup: |
      from strictyaml import Map, Enum, Int, MapPattern, YAMLValidationError, load
      from ensure import Ensure

      schema = Map({"a": Enum([1, 2, 3], item_validator=Int())})
  variations:
    Parse correctly:
      given:
        yaml_snippet: 'a: 1'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1})

    Invalid because D is not an integer:
      given:
        yaml_snippet: 'a: D'
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: D
                   ^ (line: 1)

    Invalid because 4 is not in enum:
      given:
        yaml_snippet: 'a: 4'
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: "when expecting one of: 1, 2, 3\nfound an arbitrary integer\n\
              \  in \"<unicode string>\", line 1, column 1:\n    a: '4'\n     ^ (line:\
              \ 1)"
    Invalid because blank string is not in enum:
      given:
        yaml_snippet: 'a:'
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: "when expecting an integer\nfound a blank string\n  in \"<unicode\
              \ string>\", line 1, column 1:\n    a: ''\n     ^ (line: 1)"
