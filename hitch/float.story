Floats:
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object representing
    a decimal - e.g. YAML(1.0000000000000001)
    
    To get a python float literal, use .data.
    
    Parsing and validating as a Decimal is best for
    values which require precision, but float is better
    for values for which precision is not required.
  preconditions:
    setup: |
      from strictyaml import Map, Float, load

      schema = Map({"a": Float(), "b": Float()})

    yaml_snippet: |
      a: 1.00000000000000000001
      b: 5.4135
  variations:
    Use .data to get float type:
      preconditions:
        code: type(load(yaml_snippet, schema)["a"].data)
      scenario:
        - Should be equal to: float
    
    Equal to equivalent float which is different number:
      preconditions:
        code: load(yaml_snippet, schema)
      scenario:
        - Should be equal to: '{"a": 1.0, "b": 5.4135}'

    Cast to str:
      preconditions:
        code: str(load(yaml_snippet, schema)["a"])
      scenario:
        - Should be equal to: |
            "1.0"
    
    Cast to float:
      preconditions:
        code: float(load(yaml_snippet, schema)["a"])
      scenario:
        - Should be equal to: 1.0

    Greater than:
      preconditions:
        code: load(yaml_snippet, schema)["a"] > 0
      scenario:
        - Should be equal to: True
        
    Less than:
      preconditions:
        code: load(yaml_snippet, schema)["a"] < 0
      scenario:
        - Should be equal to: False

    Cannot cast to bool:
      preconditions:
        code: bool(load(yaml_snippet, schema)['a'])
      scenario:
        - Raises Exception:
            exception type: exceptions.TypeError
            message: |-
              Cannot cast 'YAML(1.0)' to bool.
              Use bool(yamlobj.value) or bool(yamlobj.text) instead.


    Cannot parse non-float:
      preconditions:
        yaml_snippet: |
          a: string
          b: 2
        code: load(yaml_snippet, schema)
      scenario:
        - Raises Exception:
            exception type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a float
              found non-float
                in "<unicode string>", line 1, column 1:
                  a: string
                   ^ (line: 1)
