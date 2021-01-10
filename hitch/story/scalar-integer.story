Integers (Int):
  docs: scalar/integer
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object, not
    the value directly to give you more flexibility
    and control over what you can do with the YAML.

    This is what that can object can do - in many
    cases if parsed as a integer, it will behave in
    the same way.
  given:
    yaml_snippet: |
      a: 1
      b: 5
    setup: |
      from strictyaml import Map, Int, load
      from ensure import Ensure

      schema = Map({"a": Int(), "b": Int()})

      parsed = load(yaml_snippet, schema)
  variations:
    Parsed correctly:
      steps:
      - Run: |
          Ensure(parsed).equals({"a": 1, "b": 5})

    Has underscores:
      given:
        yaml_snippet: |
          a: 10_000_000
          b: 10_0_0
      steps:
        - Run:
            code: |
              Ensure(load(yaml_snippet, schema).data).equals({"a": 10000000, "b": 1000})

    Cast with str:
      steps:
      - Run: Ensure(str(parsed["a"])).equals("1")

    Cast with float:
      steps:
      - Run: Ensure(float(parsed["a"])).equals(1.0)

    Greater than:
      steps:
      - Run: Ensure(parsed["a"] > 0).equals(True)

    Less than:
      steps:
      - Run: Ensure(parsed["a"] < 2).equals(True)

    To get actual int, use .data:
      steps:
      - Run: Ensure(type(load(yaml_snippet, schema)["a"].data) is int).equals(True)

    Cannot cast to bool:
      steps:
      - Run:
          code: bool(load(yaml_snippet, schema)['a'])
          raises:
            message: |-
              Cannot cast 'YAML(1)' to bool.
              Use bool(yamlobj.data) or bool(yamlobj.text) instead.


Invalid scalar integer:
  based on: strictyaml
  given:
    yaml_snippet: |
      a: string
      b: 2
    setup: |
      from strictyaml import Map, Int, load

      schema = Map({"a": Int(), "b": Int()})
  steps:
  - Run:
      code: load(yaml_snippet, schema)
      raises:
        type: strictyaml.exceptions.YAMLValidationError
        message: |-
          when expecting an integer
          found arbitrary text
            in "<unicode string>", line 1, column 1:
              a: string
               ^ (line: 1)
