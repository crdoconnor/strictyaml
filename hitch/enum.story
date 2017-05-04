Enum validation:
  based on: strictyaml
  preconditions:
    files:
      valid_sequence_1.yaml: |
        a: A
      valid_sequence_2.yaml: |
        a: B
      valid_sequence_3.yaml: |
        a: C
      invalid_sequence_1.yaml: |
        a: D
      invalid_sequence_2.yaml: |
        a: yes
      invalid_sequence_3.yaml: |
        a: 1
  scenario:
    - Run command: |
        from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load

        schema = Map({"a": Enum(["A", "B", "C"])})

    - Assert True: 'load(valid_sequence_1, schema) == {"a": "A"}'
    
    - Assert True: 'load(valid_sequence_2, schema) == {"a": "B"}'
    
    - Assert True: 'load(valid_sequence_3, schema) == {"a": "C"}'
    
    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: ''

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: ''
        
    - Assert Exception:
        command: load(invalid_sequence_3, schema)
        exception: ''

