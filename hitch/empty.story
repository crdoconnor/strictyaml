Empty validation (EmptyNone, EmptyDict, EmptyList):
  description: |
    Sometimes you may wish to not specify a value or specify
    that it does not exist.
    
    Using StrictYAML you can accept this as a valid value and
    have it parsed to one of three things - None, {} (empty dict),
    or [] (empty list).
  based on: strictyaml
  scenario:
    - Run command: |
        from strictyaml import Map, Enum, EmptyNone, EmptyDict, EmptyList, load

    - Variable:
        name: valid_sequence_1
        value: 'a: A'

    - Returns True: 'load(valid_sequence_1, Map({"a": Enum(["A", "B",]) | EmptyNone()})) == {"a": "A"}'

    - Variable:
        name: valid_sequence_2
        value: 'a:'

    - Returns True: 'load(valid_sequence_2, Map({"a": Enum(["A", "B",]) | EmptyNone()})) == {"a": None}'

    - Variable:
        name: valid_sequence_3
        value: 'a:'

    - Returns True: 'load(valid_sequence_3, Map({"a": Enum(["A", "B",]) | EmptyDict()})) == {"a": {}}'

    - Variable:
        name: valid_sequence_4
        value: 'a:'

    - Returns True: 'load(valid_sequence_3, Map({"a": Enum(["A", "B",]) | EmptyList()})) == {"a": []}'

    - Variable:
        name: invalid_sequence_1
        value: 'a: C'

    - Raises Exception:
        command: 'load(invalid_sequence_1, Map({"a": Enum(["A", "B",]) | EmptyNone()}))'
        exception: |
          when expecting an empty value
          found non-empty value
            in "<unicode string>", line 1, column 1:
              a: C
               ^

