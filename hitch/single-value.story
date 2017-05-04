Single value:
  based on: strictyaml
  description: |
     The minimal YAML document that is parsed by StrictYAML is
     a string of characters which parses by default to a string
     unless a scalar validator is used.
     
     Where standard YAML implicitly converts certain strings
     to other types, StrictYAML will only parse to strings
     unless otherwise directed.
  scenario:
    - Code: |
        from strictyaml import Str, Int, load

    - Raises exception:
        command: load(None, Str())
        exception: 'StrictYAML can only read a string of valid YAML.'

    - Returns True: |
        load("1", Str()) == "1"

    - Returns True:
        command: |
          load("1", Int()) == 1

    - Returns True:
        why: an empty value is parsed as a blank string by default.
        command: |
          load("x:") == {"x": ""}

    - Returns True:
        why: An empty document is parsed as a blank string by default.
        command: |
          load("", Str()) == ""

    - Returns True:
        why: 'Other YAML parsers return {None: None}'
        command: |
          load("null: null") == {"null": "null"}

    - Returns True:
        why: 'Other YAML parsers return floats {2.0: 2.0}'
        command: |
          load("2.0: 2.0") == {"2.0": "2.0"}

    - Returns True:
        why: 'Other YAML parsers return ints {2: 2}'
        command: |
          load("2: 2") == {"2": "2"}

    - Returns True:
        why: 'Other YAML parsers return bools {True: True}'
        command: |
          load("true: True") == {"true": "True"}

    - Returns True:
        why: Other YAML parsers return dates
        command: |
          load("2016-02-01: 2016-02-01") == {"2016-02-01": "2016-02-01"}
