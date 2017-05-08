Optional validation:
  based on: strictyaml
  description: |
    Not every key in a YAML mapping will be required. If
    you use the "Optional('key')" validator with YAML,
    you can signal that a key/value pair is not required.
  preconditions:
    files:
      valid_sequence_1.yaml: |
        a: 1
        b: yes
      valid_sequence_2.yaml: |
        a: 1
        b: no
      valid_sequence_3.yaml: |
        a: 1
      valid_sequence_4.yaml: |
        a: 1
        b:
          x: y
          y: z
      invalid_sequence_1.yaml: |
        b: 2
      invalid_sequence_2.yaml: |
        a: 1
        b: 2
      invalid_sequence_3.yaml: |
        a: 1
        b: yes
        c: 3
  scenario:
    - Code: |
        from strictyaml import Map, Int, Str, Bool, Optional, load

        schema = Map({"a": Int(), Optional("b"): Bool(), })

    - Returns True: 'load(valid_sequence_1, schema) == {"a": 1, "b": True}'

    - Returns True: 'load(valid_sequence_2, schema) == {"a": 1, "b": False}'

    - Returns True: 'load(valid_sequence_3, schema) == {"a": 1}'

    - Code: |
        load(valid_sequence_4, Map({"a": Int(), Optional("b"): Map({Optional("x"): Str(), Optional("y"): Str()})}))

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 1, column 1:
              b: '2'
               ^

    - Raises Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 2, column 1:
              b: '2'
              ^

    - Raises Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'c'
            in "<unicode string>", line 3, column 1:
              c: '3'
              ^
