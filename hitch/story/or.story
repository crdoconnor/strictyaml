Either/or schema validation of different, equally valid different kinds of YAML:
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
      from strictyaml import Map, Seq, Bool, Int, Str, YAMLValidationError, load
      from ensure import Ensure

      schema = Str() | Map({"a": Bool() | Int()})
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

    Invalid combinations of more than one map:
      given:
        yaml_snippet: 'a: x'
      steps:
      - Run:
          code: |
            load(yaml_snippet, Map({"a": Str()}) | Map({"b": Str()}))
          raises:
            type: strictyaml.exceptions.InvalidValidatorError
            message: You tried to Or ('|') together 2 Map validators. Try using revalidation
              instead.

    Invalid combinations of more than one seq:
      given:
        yaml_snippet: |
          - 1
          - 2
      steps:
      - Run:
          code: |
            load(yaml_snippet, Seq(Int()) | Seq(Str()))
          raises:
            type: strictyaml.exceptions.InvalidValidatorError
            message: You tried to Or ('|') together 2 Seq validators. Try using revalidation
              instead.

    Change item after validated:
      given:
        yaml_snippet: 'a: yes'
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            yaml['a'] = 5
            assert yaml['a'] == 5
