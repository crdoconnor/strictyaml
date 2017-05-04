Scalar integer:
  based on: strictyaml
  preconditions:
    files:
      valid_sequence.yaml: |
        a: 1
        b: 5
  scenario:
    - Run command: |
        from strictyaml import Map, Int, YAMLValidationError, load

        schema = Map({"a": Int(), "b": Int()})

    - Assert True: 'load(valid_sequence, schema) == {"a": 1, "b": 5}'

    - Assert True: 'str(load(valid_sequence, schema)["a"]) == "1"'

    - Assert True: 'float(load(valid_sequence, schema)["a"]) == 1.0'

    - Assert True: 'load(valid_sequence, schema)["a"] > 0'

    - Assert True: 'load(valid_sequence, schema)["a"] < 2'

    - Assert Exception:
        command: bool(load(valid_sequence, schema)['a'])
        exception: Cannot cast
