Or validation:
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
    - Run command: |
        from strictyaml import Map, Bool, Int, YAMLValidationError, load

        schema = Map({"a": Bool() | Int()})

    - Assert True: 'load(valid_sequence_1, schema) == {"a" : True}'

    - Assert True: 'load(valid_sequence_2, schema) == {"a" : 5}'

    - Assert True: 'load(valid_sequence_3, schema) == {"a" : False}'

    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: A
               ^

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: B
               ^

    - Assert Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: '3.14'
               ^
