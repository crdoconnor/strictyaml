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
      from strictyaml import Map, Decimal, load, as_document
      from strictyaml.exceptions import YAMLSerializationError
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
            type: TypeError
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

    Serialize without losing precision:
      steps:
      - Run: |
          document = as_document({"a": Dec("1.00000000000000000001"), "b": "5.4135"}, schema)
          Ensure(document.as_yaml()).equals(yaml_snippet)
          Ensure(load(document.as_yaml(), schema).data).equals(document.data)

    Update a decimal value:
      steps:
      - Run: |
          document = load(yaml_snippet, schema)
          document["a"] = Dec(0)
          document["b"] = Dec("1.00000000000000000001")
          Ensure(document.as_yaml()).equals("a: 0\nb: 1.00000000000000000001\n")

    Serialize numeric values and decimal strings:
      steps:
      - Run: |
          for value in [0, -12, 0.25, Dec("2.500"), "1_000.5", "+2.50", "1e-7"]:
              document = as_document({"a": value}, Map({"a": Decimal()}))
              Ensure(document.as_yaml()).equals("a: {}\n".format(value))
              Ensure(document.data["a"]).equals(Dec(str(value)))

    Reject values which cannot be parsed as decimals:
      steps:
      - Run: |
          invalid_values = [True, None, [], {}, "x", "", ".", "-", "_", "1e_",
                            float("inf"), float("nan"), Dec("Infinity"), Dec("NaN")]
          for value in invalid_values:
              try:
                  as_document({"a": value}, Map({"a": Decimal()}))
              except YAMLSerializationError as error:
                  Ensure(str(error)).equals("when expecting a decimal, got '{}'".format(value))
              else:
                  raise AssertionError("Serialized invalid decimal: {!r}".format(value))
