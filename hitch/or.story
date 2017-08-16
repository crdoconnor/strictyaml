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

      schema = Map({"a": Bool() | Int()})
    code: load(yaml_snippet, schema)
  variations:
    Boolean first choice true:
      preconditions:
        yaml_snippet: 'a: yes'
      scenario:
        - Should be equal to: '{"a": True}'

    Boolean first choice false:
      preconditions:
        yaml_snippet: 'a: no'
      scenario:
        - Should be equal to: '{"a": False}'

    Int second choice:
      preconditions:
        yaml_snippet: 'a: 5'
      scenario:
        - Should be equal to: '{"a" : 5}'
    
    Invalid not bool or int:
      preconditions:
        yaml_snippet: 'a: A'
      scenario:
        - Raises exception: |
            when expecting an integer
            found non-integer
              in "<unicode string>", line 1, column 1:
                a: A
