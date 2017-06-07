What line:
  based on: strictyaml
  importance: 2
  description: |
    Line numbers, the text of an item and text of surrounding lines
    can be grabbed from returned YAML objects - using .start_line,
    .end_line, lines(), lines_before(x) and lines_after(x).
  scenario:
    - Run command: |
        from strictyaml import Map, Str, YAMLValidationError, load

        schema = Map({"y": Str(), "a": Str(), "b": Str(), "c": Str(), "d": Str()})

    - Variable:
        name: commented_yaml
        value: |
          y: p
          # Some comment
          
          a: |
            x
          
          # Another comment
          b: y
          c: a
          
          d: b


    - Returns True: 'load(commented_yaml, schema)["a"].start_line == 2'

    - Returns True: 'load(commented_yaml, schema)["a"].end_line == 7'

    - Returns True: 'load(commented_yaml, schema)["d"].start_line == 10'

    - Returns True: 'load(commented_yaml, schema)["d"].end_line == 11'

    - Returns True: 'load(commented_yaml, schema).keys()[1].start_line == 2'

    - Returns True: 'load(commented_yaml, schema).start_line == 1'

    - Returns True: 'load(commented_yaml, schema).end_line == 11'

    - Variable:
        name: yaml_snippet
        value: |
          # Some comment
          
          a: |
            x
          
          # Another comment


    - Returns True: |
        load(commented_yaml, schema)['a'].lines() == yaml_snippet.strip()

    - Returns True: |
        load(commented_yaml, schema)['a'].lines_before(1) == "y: p"

    - Should be equal:
        lhs: load(commented_yaml, schema)['a'].lines_after(4)
        rhs: |
          "b: y\nc: a\n\nd: b"
    
    - Variable:
        name: yaml_with_list
        value: |
          a:
            b:
            - 1
            
            - 2
            
            - 3
            - 4
    
    - Run command: Path("/tmp/t").write_text(load(yaml_with_list).as_yaml())
    
    - Should be equal:
        lhs: load(yaml_with_list)['a']['b'][1].start_line
        rhs: 5

    - Should be equal:
        lhs: load(yaml_with_list)['a']['b'][1].end_line
        rhs: 5
