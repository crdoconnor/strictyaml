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
      from strictyaml import Map, Enum, EmptyNone, EmptyDict, EmptyList, load
  variations:
    EmptyNone no empty value:
      preconditions:
        code: |
          load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyNone()}))
        yaml_snippet: 'a: A'
      scenario:
      - Should be equal to: '{"a": "A"}'
    EmptyNone with empty value:
      preconditions:
        code: |
          load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyNone()}))
        yaml_snippet: 'a:'
      scenario:
      - Should be equal to: '{"a": None}'

    EmptyDict:
      preconditions:
        code: |
          load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyDict()}))
        yaml_snippet: 'a:'
      scenario:
      - Should be equal to: '{"a": {}}'
    EmptyList:
      preconditions:
        code: |
          load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyList()}))
        yaml_snippet: 'a:'
      scenario:
      - Should be equal to: '{"a": []}'
    Non-empty value:
      preconditions:
        code: |
          load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyNone()}))
        yaml_snippet: 'a: C'
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting an empty value
            found non-empty value
              in "<unicode string>", line 1, column 1:
                a: C
                 ^ (line: 1)
