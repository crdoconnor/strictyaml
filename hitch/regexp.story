Regex strings:
  based on: strictyaml
  description: |
    StrictYAML can validate regular expressions and return a
    string. If the regular expression does not match, an
    exception is raised.
  scenario:
    - Code: |
        from strictyaml import Regex, Map, load

        schema = Map({"a": Regex(u"[1-4]"), "b": Regex(u"[5-9]")})

    - Variable:
        name: valid
        value: |
          a: 1
          b: 5

    - Returns True: 'load(valid, schema) == {"a": "1", "b": "5"}'

    - Variable:
        name: invalid
        value: |
          a: 5
          b: 5

    - Raises Exception:
        command: load(invalid, schema)
        exception: found non-matching string
