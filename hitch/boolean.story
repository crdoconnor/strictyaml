Boolean validation:
  based on: strictyaml
  description: |
    Boolean values can be parsed using a Bool
    validator. It case-insensitively interprets
    "yes", "true", "1", "on" as True and their
    opposites as False.

    Any values that are not one of those will
    will cause a validation error.
  preconditions:
    files:
      valid_sequence.yaml: |
        a: yes
        b: true
        c: on
        d: 1
        e: 0
        f: Off
        g: FALSE
        h: no
      invalid_sequence.yaml: |
        a: yâs
  scenario:
    - Code: |
        from strictyaml import Bool, Str, MapPattern, YAMLValidationError, load

        schema = MapPattern(Str(), Bool())

    - Returns True:
        why: Even though it returns a YAML object, that YAML object resolves to True/False
        command: 'load(valid_sequence, schema)["e"] == False'

    - Returns True:
        why: Using .value you can get the actual boolean value parsed
        command: 'load(valid_sequence, schema)["a"].value is True'

    - Returns True:
        why: Whereas using .text you can get the text
        command: 'load(valid_sequence, schema)["g"].text == "FALSE"'

    - Raises Exception:
        why: |
          The YAML boolean object cannot be cast directly to string since
          the expected value is ambiguous ("False" or "FALSE"?)
        command: str(load(valid_sequence, schema)["g"])
        exception: Cannot cast

    - Raises Exception:
        command: load(invalid_sequence, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 1, column 1:
              a: "y\xE2s"
               ^ (line: 1)
