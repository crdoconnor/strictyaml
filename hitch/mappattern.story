Map Pattern:
  based on: strictyaml
  description: |
    When you do not wish to let the user define the key
    names in a mapping and and only specify what type the
    keys are, use a MapPattern.

    When you wish to specify the exact key name, use the
    'Map' validator instead.
  scenario:
    - Run command: |
        from strictyaml import MapPattern, Int, Str, YAMLValidationError, load

        schema = MapPattern(Str(), Int())

    - Variable:
        name: valid_sequence_1
        value: |
          â: 1
          b: 2

    - Returns True: 'load(valid_sequence_1, schema) == {u"â": 1, "b": 2}'

    - Variable:
        name: valid_sequence_2
        value: |
          a: 1
          c: 3

    - Returns True: 'load(valid_sequence_2, schema) == {"a": 1, "c": 3}'

    - Variable:
        name: valid_sequence_3
        value: 'a: 1'

    - Returns True: 'load(valid_sequence_3, schema) == {"a": 1, }'

    - Variable:
        name: invalid_sequence_1
        value: |
          b: b

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              b: b
               ^

    - Variable:
        name: invalid_sequence_2
        value: |
          a: a
          b: 2

    - Raises Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: a
               ^

    - Variable:
        name: invalid_sequence_3
        value: |
          a: 1
          b: yâs
          c: 3

    - Raises Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 2, column 1:
              b: "y\xE2s"
              ^
