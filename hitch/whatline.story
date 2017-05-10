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

    - Returns True: 'load(commented_yaml, schema).keys()[1].start_line == 2'

    - Returns True: 'load(commented_yaml, schema).start_line == 1'

    - Returns True: 'load(commented_yaml, schema).end_line == 10'

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
    - Returns True: |
        load(commented_yaml, schema)['a'].lines_after(4) == "b: y\nc: a\nd: b\n"

