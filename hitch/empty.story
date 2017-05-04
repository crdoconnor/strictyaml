Empty validation:
  based on: strictyaml
  preconditions:
    files:
      valid_sequence_1.yaml: |
        a: A
      valid_sequence_2.yaml: |
        a:
      valid_sequence_3.yaml: |
        a:
      valid_sequence_4.yaml: |
        a:
      invalid_sequence_1.yaml: |
        a: C
  scenario:
    - Run command: |
        from strictyaml import Map, Enum, EmptyNone, EmptyDict, EmptyList, YAMLValidationError, load

    - Assert True: 'load(valid_sequence_1, Map({"a": Enum(["A", "B",]) | EmptyNone()})) == {"a": "A"}'

    - Assert True: 'load(valid_sequence_2, Map({"a": Enum(["A", "B",]) | EmptyNone()})) == {"a": None}'

    - Assert True: 'load(valid_sequence_3, Map({"a": Enum(["A", "B",]) | EmptyDict()})) == {"a": {}}'

    - Assert True: 'load(valid_sequence_3, Map({"a": Enum(["A", "B",]) | EmptyList()})) == {"a": []}'

    - Assert Exception:
        command: 'load(invalid_sequence_1, Map({"a": Enum(["A", "B",]) | EmptyNone()}))'
        exception: |
          when expecting an empty value
          found non-empty value
            in "<unicode string>", line 1, column 1:
              a: C
               ^

