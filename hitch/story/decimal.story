Decimal numbers (Decimal):
  docs: scalar/decimal
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object representing
    a decimal, not the value directly to give you more
    flexibility and control over what you can do with the
    YAML.

    This is what that can object can do - in many
    cases if parsed as a decimal, it will behave in
    the same way.

    To get a python decimal.Decimal object, use .data.

    Parsing and validating as a Decimal is best for
    values which require precision, like prices.
  given:
    setup: |
      from strictyaml import Map, Decimal, load
      from decimal import Decimal as Dec
      from ensure import Ensure

      schema = Map({"a": Decimal(), "b": Decimal()})

    yaml_snippet: |
      a: 1.00000000000000000001
      b: 5.4135
  variations:
    .data to get Decimal object:
      steps:
      - Run: Ensure(type(load(yaml_snippet, schema)["a"].data) is Dec).is_true()

    Valid:
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema)).equals({"a": Dec('1.00000000000000000001'), "b": Dec('5.4135')})

    Cast to str:
      steps:
      - Run:
          Ensure(str(load(yaml_snippet, schema)['a'])).equals("1.00000000000000000001")


    Cast to float:
      steps:
      - Run:
          Ensure(float(load(yaml_snippet, schema)["a"])).equals(1.0)

    Greater than:
      steps:
      - Run:
          Ensure(load(yaml_snippet, schema)["a"] > Dec('1.0')).is_true()

    Less than which would not work for float:
      steps:
      - Run:
          Ensure(load(yaml_snippet, schema)["a"] < Dec('1.00000000000000000002')).is_true()

    Cannot cast to bool:
      steps:
      - Run: 
          code: bool(load(yaml_snippet, schema)['a'])
          raises:
            message: |-
              Cannot cast 'YAML(1.00000000000000000001)' to bool.
              Use bool(yamlobj.data) or bool(yamlobj.text) instead.

    Invalid:
      given:
        yaml_snippet: |
          a: string
          b: 2
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a decimal
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: string
                   ^ (line: 1)
