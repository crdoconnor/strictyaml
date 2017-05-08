Or validation:
  description: |
    StrictYAML can be directed to parse two different elements or
    blocks of YAML.

    If the first thing does not parse correctly, it attempts to
    parse the second. If the second does not parse correctly,
    it raises an exception.
  based on: strictyaml
  preconditions:
    files:
      valid_sequence_1.yaml: |
        a: yes
      valid_sequence_2.yaml: |
        a: 5
      valid_sequence_3.yaml: |
        a: no
      invalid_sequence_1.yaml: |
        a: A
      invalid_sequence_2.yaml: |
        a: B
      invalid_sequence_3.yaml: |
        a: 3.14
  scenario:
    - Code: |
        from strictyaml import Map, Bool, Int, YAMLValidationError, load

        schema = Map({"a": Bool() | Int()})

    - Returns True: 'load(valid_sequence_1, schema) == {"a" : True}'

    - Returns True: 'load(valid_sequence_2, schema) == {"a" : 5}'

    - Returns True: 'load(valid_sequence_3, schema) == {"a" : False}'

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: A
               ^

    - Raises Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: B
               ^

    - Raises Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: '3.14'
               ^
