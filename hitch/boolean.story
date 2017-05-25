Boolean validation:
  based on: strictyaml
  description: |
    Boolean values can be parsed using a Bool
    validator. It case-insensitively interprets
    "yes", "true", "1", "on" as True and their
    opposites as False.

    Any values that are not one of those will
    will cause a validation error.
  scenario:
    - Code: |
        from strictyaml import Bool, Str, MapPattern, YAMLValidationError, load

        schema = MapPattern(Str(), Bool())

    - Variable:
        name: valid_sequence
        value: |
          a: yes
          b: true
          c: on
          d: 1
          e: True
          v: False
          w: 0
          x: Off
          y: FALSE
          z: no

    - Returns True:
        command: |
            load(valid_sequence, schema) == \
              {"a": True, "b": True, "c": True, "d": True, "e": True, "v": False, "w": False, "x": False, "y": False, "z": False,}

    - Returns True:
        why: Even though it returns a YAML object, that YAML object resolves to True/False
        command: 'load(valid_sequence, schema)["w"] == False'

    - Returns True:
        why: Using .value you can get the actual boolean value parsed
        command: 'load(valid_sequence, schema)["a"].value is True'

    - Returns True:
        why: Whereas using .text you can get the text
        command: 'load(valid_sequence, schema)["y"].text == "FALSE"'

    - Raises Exception:
        why: |
          The YAML boolean object cannot be cast directly to string since
          the expected value is ambiguous ("False" or "FALSE"?)
        command: str(load(valid_sequence, schema)["y"])
        exception: Cannot cast

    - Variable:
        name: invalid_sequence
        value: 'a: yâs'

    - Raises Exception:
        command: load(invalid_sequence, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 1, column 1:
              a: "y\xE2s"
               ^ (line: 1)
