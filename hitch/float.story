Float:
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object representing
    a decimal, not the value directly to give you more
    flexibility and control over what you can do with the
    YAML.
    
    This is what that can object can do - in many
    cases if parsed as a decimal, it will behave in
    the same way.
    
    To get a python float object, use .data.
    
    Parsing and validating as a Decimal is best for
    values which require precision, but float is better
    for values for which precision is not required.
  preconditions:
    files:
      valid_sequence.yaml: |
        a: 1.00000000000000000001
        b: 5.4135
      invalid_sequence_2.yaml: |
        a: string
        b: 2
  scenario:
    - Code: |
        from strictyaml import Map, Float, load

        schema = Map({"a": Float(), "b": Float()})

    - Returns True: 'load(valid_sequence, schema) == {"a": 1.0, "b": 5.4135}'
    - Returns True: 'str(load(valid_sequence, schema)["a"]) == "1.0"'
    - Returns True: 'float(load(valid_sequence, schema)["a"]) == 1.0'
    - Returns True: 'load(valid_sequence, schema)["a"] > 0'
    - Returns True: 'load(valid_sequence, schema)["a"] < 2'
    - Raises Exception:
        command: bool(load(valid_sequence, schema)['a'])
        exception: Cannot cast

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a float
          found non-float
            in "<unicode string>", line 1, column 1:
              a: string
               ^

    - Returns True:
        why: To just get an actual float, use .data
        command: 'type(load(valid_sequence, schema)["a"].data) is float'
