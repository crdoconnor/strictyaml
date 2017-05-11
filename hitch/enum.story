Enum validation (Enum):
  description: |
    StrictYAML allows you to ensure that a scalar
    value can only be one of a set number of items.
    
    It will throw an exception if any strings not
    in the list are found.
  based on: strictyaml
  scenario:
    - Run command: |
        from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load

        schema = Map({"a": Enum(["A", "B", "C"])})

    - Variable:
        name: valid_sequence_1
        value: 'a: A'

    - Returns True: 'load(valid_sequence_1, schema) == {"a": "A"}'

    - Variable:
        name: valid_sequence_2
        value: 'a: B'

    - Returns True: 'load(valid_sequence_2, schema) == {"a": "B"}'

    - Variable:
        name: valid_sequence_3
        value: 'a: C'

    - Returns True: 'load(valid_sequence_3, schema) == {"a": "C"}'

    - Variable:
        name: invalid_sequence_1
        value: 'a: D'

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: ''

    - Variable:
        name: invalid_sequence_2
        value: 'a: yes'

    - Raises Exception:
        command: load(invalid_sequence_2, schema)
        exception: ''

    - Variable:
        name: invalid_sequence_3
        value: 'a: 1'

    - Raises Exception:
        command: load(invalid_sequence_3, schema)
        exception: ''

