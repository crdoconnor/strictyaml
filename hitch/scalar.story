Scalar validation:
  based on: strictyaml
  preconditions:
    files:
      valid_sequence.yaml: |
        a: 1
        b: yes
        c: string
        d: 3.141
        e: 3.1415926535
      invalid_sequence_1.yaml: |
        a: 1
        b: 2
        c: string
        d: 3.141
        e: 3.1415926535
      invalid_sequence_2.yaml: |
        a: string
        b: 2
        c: string
        d: 3.141
        e: 3.1415926535
      invalid_sequence_3.yaml: |
        a: 1
        b: yes
        c: string
        d: not â float
        e: 3.1415926535
      invalid_sequence_4.yaml: |
        a: 1
        b: yes
        c: string
        d: 3.141
        e: not â decimal
  scenario:
    - Run command: |
        from strictyaml import Map, Int, Bool, Float, Str, Decimal, YAMLValidationError, load
        import decimal

        schema = Map({"a": Int(), "b": Bool(), "c": Str(), "d": Float(), "e": Decimal()})

    - Assert True: 'load(valid_sequence, schema) == {"a": 1, "b": True, "c": "string", "d": 3.141, "e": decimal.Decimal("3.1415926535")}'

    - Assert True: 'load(valid_sequence, schema)["a"].is_scalar()'

    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting a boolean value (one of "yes", "true", "on", "1", "no", "false", "off", "0")
          found non-boolean
            in "<unicode string>", line 2, column 1:
              b: '2'
              ^

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: string
               ^

    - Assert Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          when expecting a float
          found non-float
            in "<unicode string>", line 4, column 1:
              d: "not \xE2 float"
              ^

    - Assert Exception:
        command: load(invalid_sequence_4, schema)
        exception: |
          when expecting a decimal
          found non-decimal
            in "<unicode string>", line 5, column 1:
              e: "not \xE2 decimal"
              ^
