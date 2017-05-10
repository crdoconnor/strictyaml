Comma separated:
  based on: strictyaml
  description: |
    Comma-separated values can be validated and parsed
    using the CommaSeparated validator.

    Note that the space following the commas is stripped by
    default when parsed.
  scenario:
    - Run command: |
        from strictyaml import CommaSeparated, Int, Str, Map, load

        int_schema = Map({"a": CommaSeparated(Int())})

        str_schema = Map({"a": CommaSeparated(Str())})

    - Variable:
        name: valid_sequence
        value: |
          a: 1, 2, 3

    - Returns True: 'load(valid_sequence, int_schema) == {"a": [1, 2, 3]}'

    - Returns True: 'load(valid_sequence, str_schema) == {"a": ["1", "2", "3"]}'

    - Variable:
        name: invalid_sequence
        value: |
          a: 1, x, 3

    - Raises exception:
        command: load(invalid_sequence, int_schema)
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              a: 1, x, 3
               ^
