Mapping representation:
  based on: strictyaml
  scenario:
    - Code: |
        from strictyaml import Map, Int, load

        schema = Map({"a": Int(), "b": Int(), "c": Int()})

        nested_schema = Map({"a": Int(), "b": Int(), "c": Map({"x": Int(), "y": Int()})})

    - Variable:
        name: valid_sequence
        value: |
          a: 1
          b: 2
          c: 3

    - Returns True: 'load(valid_sequence, schema) == {"a": 1, "b": 2, "c": 3}'

    - Returns True: '"a" in load(valid_sequence, schema)'

    - Returns True: 'load(valid_sequence, schema).items() == [("a", 1), ("b", 2), ("c", 3)]'

    - Returns True: 'load(valid_sequence, schema).values() == [1, 2, 3]'

    - Returns True: 'load(valid_sequence, schema).keys() == ["a", "b", "c"]'

    - Returns True: 'load(valid_sequence, schema)["a"] == 1'

    - Returns True: 'load(valid_sequence, schema).get("a") == 1'

    - Assert True: 'load(valid_sequence, schema).get("nonexistent") is None'

    - Assert True: 'len(load(valid_sequence, schema)) == 3'

    - Assert True: 'load(valid_sequence, schema).is_mapping()'

    - Variable:
        name: nested
        value: |
          a: 1
          b: 2
          c:
            x: 1
            y: 2

    - Run command: |
        unmodified = load(nested, nested_schema)
        modified = unmodified.copy()

        modified['b'] = unmodified['c']

    - Assert True: 'modified == {"a": 1, "b": {"x": 1, "y": 2}, "c": {"x": 1, "y": 2}}'

