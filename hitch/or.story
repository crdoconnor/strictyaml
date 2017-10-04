Or validation:
  description: |
    StrictYAML can be directed to parse two different elements or
    blocks of YAML.

    If the first thing does not parse correctly, it attempts to
    parse the second. If the second does not parse correctly,
    it raises an exception.
  based on: strictyaml
  preconditions:
    setup: |
      from strictyaml import Map, Bool, Int, YAMLValidationError, load
      from ensure import Ensure

      schema = Map({"a": Bool() | Int()})
    code: load(yaml_snippet, schema)
  variations:
    Boolean first choice true:
      preconditions:
        yaml_snippet: 'a: yes'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": True})

    Boolean first choice false:
      preconditions:
        yaml_snippet: 'a: no'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": False})

    Int second choice:
      preconditions:
        yaml_snippet: 'a: 5'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 5})

    Invalid not bool or int:
      preconditions:
        yaml_snippet: 'a: A'
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting an integer
            found non-integer
              in "<unicode string>", line 1, column 1:
                a: A
                 ^ (line: 1)
