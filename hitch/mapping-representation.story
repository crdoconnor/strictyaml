Map:
  based on: strictyaml
  description: |
    When a YAML document with mappings is parsed, it is not parsed
    as a dict but as a YAML object which behaves very similarly to
    a dict, but also has some extra capabilities.
    
    You can use .items(), .keys(), .values(), look up items with
    square bracket notation, .get(key, with_default_if_nonexistent)
    and use "x in y" notation to determine key membership.
    
    To retrieve the equivalent dict (containing just other dicts, lists
    and strings/ints/etc.) use .data.
  preconditions:
    setup: |
      from strictyaml import Map, Int, load

      schema = Map({"a": Int(), "b": Int(), "c": Int()})
    yaml_snippet: |
      a: 1
      b: 2
      c: 3
  variations:
    .is_mapping():
      preconditions:
        code:  load(yaml_snippet, schema).is_mapping()
      scenario:
        - Should be equal to: True

    Equivalence with equivalent plain dict:
      preconditions:
        code:  load(yaml_snippet, schema)
      scenario:
        - Should be equal to: '{"a": 1, "b": 2, "c": 3}'

    .items():
      preconditions:
        code:  load(yaml_snippet, schema).items()
      scenario:
        - Should be equal to: '[("a", 1), ("b", 2), ("c", 3)]'
    
    Use in to detect presence of a key:
      preconditions:
        code: |
          "a" in load(yaml_snippet, schema)
      scenario:
        - Should be equal to: True
    
    .values():
      preconditions:
        code: |
          load(yaml_snippet, schema).values()
      scenario:
        - Should be equal to: '[1, 2, 3]'
    
    .keys():
      preconditions:
        code: |
          load(yaml_snippet, schema).keys()
      scenario:
        - Should be equal to: '["a", "b", "c"]'
        
    Dict lookup:
      preconditions:
        code: |
          load(yaml_snippet, schema)["a"]
      scenario:
        - Should be equal to: 1
        
    .get():
      preconditions:
        code: |
          load(yaml_snippet, schema).get("a")
      scenario:
        - Should be equal to: 1
        
    .get() nonexistent:
      preconditions:
        code: |
          load(yaml_snippet, schema).get("nonexistent")
      scenario:
        - Should be equal to: None
        
    len():
      preconditions:
        code: |
          len(load(yaml_snippet, schema))
      scenario:
        - Should be equal to: 3
