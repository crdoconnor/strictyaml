Decimal:
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object representing
    a decimal, not the value directly to give you more
    flexibility and control over what you can do with the
    YAML.
    
    This is what that can object can do - in many
    cases if parsed as a decimal, it will behave in
    the same way.
    
    To get a python decimal.Decimal object, use .data.
    
    Parsing and validating as a Decimal is best for
    values which require precision, like prices.
  scenario:
    - Code: |
        from strictyaml import Map, Decimal, load
        from decimal import Decimal as Dec

        schema = Map({"a": Decimal(), "b": Decimal()})

    - Variable:
        name: valid_sequence
        value: |
          a: 1.00000000000000000001
          b: 5.4135

    - Returns True: |
        load(valid_sequence, schema) == {"a": Dec('1.00000000000000000001'), "b": Dec('5.4135')}

    - Returns True: |
        str(load(valid_sequence, schema)["a"]) == '1.00000000000000000001'

    - Returns True: |
        float(load(valid_sequence, schema)["a"]) == 1.0

    - Returns True: |
       load(valid_sequence, schema)["a"] > Dec('1.0')

    - Returns True: |
        load(valid_sequence, schema)["a"] < Dec('1.00000000000000000002')

    - Raises Exception:
        command: bool(load(valid_sequence, schema)['a'])
        exception: Cannot cast

    - Variable:
        name: invalid_sequence_2
        value: |
          a: string
          b: 2

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a decimal
          found non-decimal
            in "<unicode string>", line 1, column 1:
              a: string
               ^

    - Returns True:
        why: To just get an actual integer, use .data
        command: 'type(load(valid_sequence, schema)["a"].data) is Dec'
