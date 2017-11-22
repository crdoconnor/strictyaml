Empty key validation:
  docs: scalar/empty
  based on: strictyaml
  description: |
    Sometimes you may wish to not specify a value or specify
    that it does not exist.

    Using StrictYAML you can accept this as a valid value and
    have it parsed to one of three things - None, {} (empty dict),
    or [] (empty list).
  given:
    setup: |
      from strictyaml import Map, Str, Enum, EmptyNone, EmptyDict, EmptyList, load
      from ensure import Ensure
    yaml_snippet: 'a:'
  variations:
    EmptyNone with empty value:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Enum(["A", "B",])}))).equals({"a": None})

    EmptyDict:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyDict() | Enum(["A", "B",])}))).equals({"a": {}})

    EmptyList:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyList() | Enum(["A", "B",])}))).equals({"a": []})

    EmptyNone no empty value:
      given:
        yaml_snippet: 'a: A'
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Enum(["A", "B",])}))).equals({"a": "A"})

    Combine Str with EmptyNone and Str is evaluated first:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": Str() | EmptyNone()}))).equals({"a": ""})


    Combine EmptyNone with Str and Str is evaluated last:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Str()}))).equals({"a": None})

    Non-empty value:
      given:
        code:
        yaml_snippet: 'a: C'
      steps:
      - Run:
          code: |
            load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyNone()}))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an empty value
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: C
                   ^ (line: 1)
