Either/or schema validation of two equally valid different kinds of YAML:
  docs: howto/either-or-validation
  description: |
    StrictYAML can be directed to parse two different elements or
    blocks of YAML.

    If the first thing does not parse correctly, it attempts to
    parse the second. If the second does not parse correctly,
    it raises an exception.
  based on: strictyaml
  given:
    setup: |
      from strictyaml import Map, Bool, Int, YAMLValidationError, load
      from ensure import Ensure

      schema = Map({"a": Bool() | Int()})
    code: load(yaml_snippet, schema)
  variations:
    Boolean first choice true:
      given:
        yaml_snippet: 'a: yes'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": True})

    Boolean first choice false:
      given:
        yaml_snippet: 'a: no'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": False})

    Int second choice:
      given:
        yaml_snippet: 'a: 5'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 5})

    Invalid not bool or int:
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: A
                   ^ (line: 1)

    Change item after validated:
      given:
        yaml_snippet: 'a: yes'
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            yaml['a'] = 5
            assert yaml['a'] == 5
