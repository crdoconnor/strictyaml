Mapping representation:
  based on: strictyaml
  description: |
    When a YAML document with mappings is parsed, it is not parsed
    as a dict but as a YAML object which behaves very similarly to
    a dict, but also has some extra capabilities.
    
    You can use .items(), .keys(), .values(), look up items with
    square bracket notation, .get(key, with_default_if_nonexistent)
    and use "x in y" notation to determine key membership.
    
    To retrieve the equivalent dict (containing just other dicts, lists
    and strings/ints/etc.) use .data.
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

    - Returns True:
        why: Tests of equivalence with equivalent plain dicts with keys/values return True.
        command: 'load(valid_sequence, schema) == {"a": 1, "b": 2, "c": 3}'

    - Returns True:
        why: Similar to dicts, you can test for the presence of a key in the mapping like this.
        command: '"a" in load(valid_sequence, schema)'


    - Returns True: 'load(valid_sequence, schema).items() == [("a", 1), ("b", 2), ("c", 3)]'

    - Returns True: 'load(valid_sequence, schema).values() == [1, 2, 3]'

    - Returns True: 'load(valid_sequence, schema).keys() == ["a", "b", "c"]'

    - Returns True: 'load(valid_sequence, schema)["a"] == 1'

    - Returns True: 'load(valid_sequence, schema).get("a") == 1'

    - Returns True: 'load(valid_sequence, schema).get("nonexistent") is None'

    - Returns True: 'len(load(valid_sequence, schema)) == 3'

    - Returns True: 'load(valid_sequence, schema).is_mapping()'

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

    #- Assert True: 'modified == {"a": 1, "b": {"x": 1, "y": 2}, "c": {"x": 1, "y": 2}}'

