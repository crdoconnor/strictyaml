Nested mapping validation:
  based on: strictyaml
  importance: 4
  description: |
    Mappings can be nested within one another, which
    will be parsed as a dict within a dict.
  scenario:
    - Run command: |
        from strictyaml import Map, Int, load

        schema = Map({"a": Map({"x": Int(), "y": Int()}), "b": Int(), "c": Int()})

    - Variable:
        name: valid_sequence
        value: |
          a:
            x: 9
            y: 8
          b: 2
          c: 3

    - Assert True: 'load(valid_sequence, schema) == {"a": {"x": 9, "y": 8}, "b": 2, "c": 3}'

    - Variable:
        name: invalid_sequence_1
        value: |
          a:
            x: 9
            z: 8
          b: 2
          d: 3

    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'z'
            in "<unicode string>", line 3, column 1:
                z: '8'
              ^

    - Variable:
        name: invalid_sequence_2
        value: |
          a: 11
          b: 2
          d: 3

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a mapping
          found non-mapping
            in "<unicode string>", line 1, column 1:
              a: '11'
               ^
