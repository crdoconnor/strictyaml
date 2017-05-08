Nested mapping validation:
  based on: strictyaml
  importance: 4
  description: |
    Mappings can be nested within one another.
  preconditions:
    files:
      valid_sequence.yaml: |
        a:
          x: 9
          y: 8
        b: 2
        c: 3
      invalid_sequence_1.yaml: |
        a:
          x: 9
          z: 8
        b: 2
        d: 3
      invalid_sequence_2.yaml: |
        a: 11
        b: 2
        d: 3
  scenario:
    - Run command: |
        from strictyaml import Map, Int, load

        schema = Map({"a": Map({"x": Int(), "y": Int()}), "b": Int(), "c": Int()})

    - Assert True: 'load(valid_sequence, schema) == {"a": {"x": 9, "y": 8}, "b": 2, "c": 3}'
    
    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'z'
            in "<unicode string>", line 3, column 1:
                z: '8'
              ^

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a mapping
          found non-mapping
            in "<unicode string>", line 1, column 1:
              a: '11'
               ^
