Scalar integer:
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object, not
    the value directly to give you more flexibility
    and control over what you can do with the YAML.

    This is what that can object can do - in many
    cases if parsed as a integer, it will behave in
    the same way.
  preconditions:
    yaml_snippet: |
      a: 1
      b: 5
    setup: |
      from strictyaml import Map, Int, load

      schema = Map({"a": Int(), "b": Int()})

      parsed = load(yaml_snippet, schema)
  variations:
    Parsed correctly:
      preconditions:
        code: parsed
      scenario:
      - Should be equal to: |
          {"a": 1, "b": 5}

    Cast with str:
      preconditions:
        code: str(parsed["a"])
      scenario:
      - Should be equal to: |
          "1"

    Cast with float:
      preconditions:
        code: float(parsed["a"])
      scenario:
      - Should be equal to: 1.0

    Greater than:
      preconditions:
        code: parsed["a"] > 0
      scenario:
      - Should be equal to: 'True'

    Less than:
      preconditions:
        code: parsed["a"] < 2
      scenario:
      - Should be equal to: 'True'

    To get actual int, use .data:
      preconditions:
        code: type(load(yaml_snippet, schema)["a"].data) is int
      scenario:
      - Should be equal to: 'True'

    Cannot cast to bool:
      preconditions:
        code: bool(load(yaml_snippet, schema)['a'])
      scenario:
      - Raises exception:
          message: |-
            Cannot cast 'YAML(1)' to bool.
            Use bool(yamlobj.data) or bool(yamlobj.text) instead.


Invalid scalar integer:
  based on: strictyaml
  preconditions:
    yaml_snippet: |
      a: string
      b: 2
    setup: |
      from strictyaml import Map, Int, load

      schema = Map({"a": Int(), "b": Int()})
    code: |
      load(yaml_snippet, schema)
  scenario:
  - Raises exception:
      exception type: strictyaml.exceptions.YAMLValidationError
      message: |-
        when expecting an integer
        found non-integer
          in "<unicode string>", line 1, column 1:
            a: string
             ^ (line: 1)
