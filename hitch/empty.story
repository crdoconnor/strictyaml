Empty key validation:
  based on: strictyaml
  description: |
    Sometimes you may wish to not specify a value or specify
    that it does not exist.

    Using StrictYAML you can accept this as a valid value and
    have it parsed to one of three things - None, {} (empty dict),
    or [] (empty list).
  preconditions:
    setup: |
      from strictyaml import Map, Str, Enum, EmptyNone, EmptyDict, EmptyList, load
      from ensure import Ensure
    yaml_snippet: 'a:'
  variations:
    EmptyNone with empty value:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Enum(["A", "B",])}))).equals({"a": None})

    EmptyDict:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyDict() | Enum(["A", "B",])}))).equals({"a": {}})

    EmptyList:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyList() | Enum(["A", "B",])}))).equals({"a": []})

    EmptyNone no empty value:
      preconditions:
        yaml_snippet: 'a: A'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Enum(["A", "B",])}))).equals({"a": "A"})

    Combine Str with EmptyNone and Str is evaluated first:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": Str() | EmptyNone()}))).equals({"a": ""})


    Combine EmptyNone with Str and Str is evaluated last:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Str()}))).equals({"a": None})

    Non-empty value:
      preconditions:
        code:
        yaml_snippet: 'a: C'
      scenario:
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
