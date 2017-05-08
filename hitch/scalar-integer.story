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
    files:
      valid_sequence.yaml: |
        a: 1
        b: 5
      invalid_sequence_2.yaml: |
        a: string
        b: 2
  scenario:
    - Code: |
        from strictyaml import Map, Int, load

        schema = Map({"a": Int(), "b": Int()})

    - Returns True: 'load(valid_sequence, schema) == {"a": 1, "b": 5}'

    - Returns True: 'str(load(valid_sequence, schema)["a"]) == "1"'

    - Returns True: 'float(load(valid_sequence, schema)["a"]) == 1.0'

    - Returns True: 'load(valid_sequence, schema)["a"] > 0'

    - Returns True: 'load(valid_sequence, schema)["a"] < 2'

    - Raises Exception:
        command: bool(load(valid_sequence, schema)['a'])
        exception: Cannot cast

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: string
               ^

    - Returns True:
        why: To just get an actual integer, use .data
        command: 'type(load(valid_sequence, schema)["a"].data) is int'
