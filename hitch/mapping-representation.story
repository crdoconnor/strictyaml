Mapping representation:
  based on: strictyaml
  preconditions:
    files:
      valid_sequence.yaml: |
        a: 1
        b: 2
        c: 3
      nested.yaml: |
        a: 1
        b: 2
        c:
          x: 1
          y: 2
  scenario:
    - Run command: |
        from strictyaml import Map, Int, YAMLValidationError, load

        schema = Map({"a": Int(), "b": Int(), "c": Int()})

        nested_schema = Map({"a": Int(), "b": Int(), "c": Map({"x": Int(), "y": Int()})})

    - Assert True: 'load(valid_sequence, schema) == {"a": 1, "b": 2, "c": 3}'

    - Assert True: '"a" in load(valid_sequence, schema)'

    - Assert True: 'load(valid_sequence, schema).items() == [("a", 1), ("b", 2), ("c", 3)]'

    - Assert True: 'load(valid_sequence, schema).values() == [1, 2, 3]'

    - Assert True: 'load(valid_sequence, schema).keys() == ["a", "b", "c"]'

    - Assert True: 'load(valid_sequence, schema)["a"] == 1'

    - Assert True: 'load(valid_sequence, schema).get("a") == 1'

    - Assert True: 'load(valid_sequence, schema).get("nonexistent") is None'

    - Assert True: 'len(load(valid_sequence, schema)) == 3'

    - Assert True: 'load(valid_sequence, schema).is_mapping()'

    - Run command: |
        unmodified = load(nested, nested_schema)
        modified = unmodified.copy()

        modified['b'] = unmodified['c']

    - Assert True: 'modified == {"a": 1, "b": {"x": 1, "y": 2}, "c": {"x": 1, "y": 2}}'

