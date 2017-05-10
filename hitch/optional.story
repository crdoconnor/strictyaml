Optional validation:
  based on: strictyaml
  description: |
    Not every key in a YAML mapping will be required. If
    you use the "Optional('key')" validator with YAML,
    you can signal that a key/value pair is not required.
  scenario:
    - Code: |
        from strictyaml import Map, Int, Str, Bool, Optional, load

        schema = Map({"a": Int(), Optional("b"): Bool(), })

    - Variable:
        name: valid_sequence_1
        value: |
          a: 1
          b: yes

    - Returns True: 'load(valid_sequence_1, schema) == {"a": 1, "b": True}'

    - Variable:
        name: valid_sequence_2
        value: |
          a: 1
          b: no

    - Returns True: 'load(valid_sequence_2, schema) == {"a": 1, "b": False}'

    - Variable:
        name: valid_sequence_3
        value: 'a: 1'

    - Returns True: 'load(valid_sequence_3, schema) == {"a": 1}'

    - Variable:
        name: valid_sequence_4
        value: |
          a: 1
          b:
            x: y
            y: z

    - Code: |
        load(valid_sequence_4, Map({"a": Int(), Optional("b"): Map({Optional("x"): Str(), Optional("y"): Str()})}))

    - Variable:
        name: invalid_sequence_1
        value: 'b: 2'

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 1, column 1:
              b: '2'
               ^

    - Variable:
        name: invalid_sequence_2
        value: |
          a: 1
          b: 2

    - Raises Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 2, column 1:
              b: '2'
              ^

    - Variable:
        name: invalid_sequence_3
        value: |
          a: 1
          b: yes
          c: 3

    - Raises Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'c'
            in "<unicode string>", line 3, column 1:
              c: '3'
              ^
