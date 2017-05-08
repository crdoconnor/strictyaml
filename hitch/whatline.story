What line:
  based on: strictyaml
  importance: 2
  description: |
    Line and context can be determined from returned YAML objects.
  preconditions:
    files:
      commented_yaml.yaml: |
        y: p
        # Some comment
        
        a: |
          x
        
        # Another comment
        b: y
        c: a
        d: b
  scenario:
    - Run command: |
        from strictyaml import Map, Str, YAMLValidationError, load

        schema = Map({"y": Str(), "a": Str(), "b": Str(), "c": Str(), "d": Str()})

    - Assert True: 'load(commented_yaml, schema)["a"].start_line == 2'
    - Assert True: 'load(commented_yaml, schema)["a"].end_line == 7'
    
    - Assert True: 'load(commented_yaml, schema).keys()[1].start_line == 2'
    
    - Assert True: 'load(commented_yaml, schema).start_line == 1'
    - Assert True: 'load(commented_yaml, schema).end_line == 10'
    - Assert True: |
        load(commented_yaml, schema)['a'].lines() == '# Some comment\n\na: |\n  x\n\n# Another comment'
    - Assert True: |
        load(commented_yaml, schema)['a'].lines_before(1) == "y: p"
    - Assert True: |
        load(commented_yaml, schema)['a'].lines_after(4) == "b: y\nc: a\nd: b\n"

