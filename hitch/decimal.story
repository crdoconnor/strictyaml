Decimal:
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
  preconditions:
    setup: |
      from strictyaml import Map, Decimal, load
      from decimal import Decimal as Dec

      schema = Map({"a": Decimal(), "b": Decimal()})

    yaml_snippet: |
      a: 1.00000000000000000001
      b: 5.4135
  variations:
    .data to get Decimal object:
      preconditions:
        code: type(load(yaml_snippet, schema)["a"].data) is Dec
      scenario:
      - Should be equal to: 'True'

    Valid:
      preconditions:
        code: load(yaml_snippet, schema)
      scenario:
      - Should be equal to: |
          {"a": Dec('1.00000000000000000001'), "b": Dec('5.4135')}

    Cast to str:
      preconditions:
        code: str(load(yaml_snippet, schema)['a'])
      scenario:
      - Should be equal to: |
          "1.00000000000000000001"

    Cast to float:
      preconditions:
        code: float(load(yaml_snippet, schema)["a"])
      scenario:
      - Should be equal to: 1.0

    Greater than:
      preconditions:
        code: load(yaml_snippet, schema)["a"] > Dec('1.0')
      scenario:
      - Should be equal to: 'True'

    Less than which would not work for float:
      preconditions:
        code: load(yaml_snippet, schema)["a"] < Dec('1.00000000000000000002')
      scenario:
      - Should be equal to: 'True'

    Cannot cast to bool:
      preconditions:
        code: bool(load(yaml_snippet, schema)['a'])
      scenario:
      - Raises exception:
          message: |-
            Cannot cast 'YAML(1.00000000000000000001)' to bool.
            Use bool(yamlobj.value) or bool(yamlobj.text) instead.

    Invalid:
      preconditions:
        yaml_snippet: |
          a: string
          b: 2
        code: load(yaml_snippet, schema)
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a decimal
            found non-decimal
              in "<unicode string>", line 1, column 1:
                a: string
                 ^ (line: 1)
