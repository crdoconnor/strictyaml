Roundtripped YAML:
  based on: strictyaml
  description: |
    Loaded YAML can be modified and dumped out again with
    comments preserved using .as_yaml().
    
    Note that due to some bugs in the library (ruamel.yaml)
    underlying StrictYAML, the YAML loaded and dumped out
    may not always look the same (e.g. 
    implementation, the YAML loaded and dumped out may not
    always look exactly the same.
  preconditions:
    files:
      commented_yaml.yaml: |
        # Some comment
        
        a: â # value comment
        
        # Another comment
        b: y
      modified_commented_yaml.yaml: |
        # Some comment
        
        a: â # value comment
        
        # Another comment
        b: x
      with_integer: |
        x: 1
  scenario:
    - Code: |
        from strictyaml import Map, Str, Int, YAMLValidationError, load

        schema = Map({"a": Str(), "b": Str()})

    - Returns True: |
        load(commented_yaml, schema).as_yaml() == commented_yaml

    - Code: |
        to_modify = load(commented_yaml, schema)

        to_modify['b'] = 'x'

    - Returns True: |
        to_modify.as_yaml() == modified_commented_yaml

    - Returns True: |
       load(with_integer, Map({"x": Int()})).as_yaml() == "x: 1\n"
