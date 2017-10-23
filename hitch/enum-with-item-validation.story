Enum with item validation:
  based on: strictyaml
  description: |
    See also: enum validation.
    
    Your enums can be a transformed string or something other than a string
    if you use an item validator.
  preconditions:
    setup: |
      from strictyaml import Map, Enum, Int, MapPattern, YAMLValidationError, load
      from ensure import Ensure

      schema = Map({"a": Enum([1, 2, 3], item_validator=Int())})
    code:
  variations:
    Parse correctly:
      preconditions:
        yaml_snippet: 'a: 1'
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1})
