No schema validation:
  based on: strictyaml
  preconditions:
    files:
      sequence_1.yaml: |
        a:
          x: 9
          y: 8
        b: 2
        c: 3
      sequence_2.yaml: |
        a:
          - 9
          - 8
        b: 2
        d: 3
      sequence_3.yaml: |
        a: 11
        b: 2
        d: 3
  scenario:
    - Run command: |
        from strictyaml import Map, Int, YAMLValidationError, load

    - Assert True: 'load(sequence_1) == {"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"}'
    - Assert True: 'load(sequence_2) == {"a": ["9", "8",], "b": "2", "d": "3"}'
    - Assert True: 'load(sequence_3) == {"a": "11", "b": "2", "d": "3"}'
