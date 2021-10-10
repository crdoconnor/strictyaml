Hexadecimal Integers (HexInt):
  docs: scalar/hexadecimal-integer
  based on: strictyaml
  description: |
    StrictYAML can interpret a hexadecimal integer
    preserving its value 
  given:
    yaml_snippet: |
      x: 0x1a
    setup: |
      from strictyaml import Map, HexInt, load
      from ensure import Ensure

      schema = Map({"x": HexInt()})

      parsed = load(yaml_snippet, schema)

  variations:
    Parsed correctly:
      steps:
      - Run: |
          Ensure(parsed).equals({"x": 26})
          Ensure(parsed.as_yaml()).equals("x: 0x1a\n")

    Uppercase:
      given:
        yaml_snippet: |
          x: 0X1A
      steps:
        - Run:
            code: |
              Ensure(load(yaml_snippet, schema).data).equals({"x": 26})
              Ensure(load(yaml_snippet, schema).as_yaml()).equals("x: 0X1A\n")

Invalid scalar hexadecimal integer:
  based on: strictyaml
  given:
    yaml_snippet: |
      x: some_string
    setup: |
      from strictyaml import Map, HexInt, load

      schema = Map({"x": HexInt()})
  steps:
  - Run:
      code: load(yaml_snippet, schema)
      raises:
        type: strictyaml.exceptions.YAMLValidationError
        message: |-
          when expecting a hexadecimal integer
          found arbitrary text
            in "<unicode string>", line 1, column 1:
              x: some_string
               ^ (line: 1)
