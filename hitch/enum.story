Enum (enum validation):
  based on: strictyaml
  description: |
    StrictYAML allows you to ensure that a scalar
    value can only be one of a set number of items.
    
    It will throw an exception if any strings not
    in the list are found.
  preconditions:
    setup: |
      from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load

      schema = Map({"a": Enum(["A", "B", "C"])})
    code: load(yaml_snippet, schema)
  variations:
    Valid A:
      preconditions:
        yaml_snippet: 'a: A'
      scenario:
        - Should be equal to: '{"a": "A"}'

    Valid B:
      preconditions:
        yaml_snippet: 'a: B'
      scenario:
        - Should be equal to: '{"a": "B"}'
        
    Valid C:
      preconditions:
        yaml_snippet: 'a: C'
      scenario:
        - Should be equal to: '{"a": "C"}'
        
    Invalid not in enum:
      preconditions:
        yaml_snippet: 'a: D'
      scenario:
        - Raises exception: |
            when expecting one of: A, B, C
        
    Invalid blank string:
      preconditions:
        yaml_snippet: 'a:'
      scenario:
        - Raises exception: |
            when expecting one of: A, B, C

