What line:
  based on: strictyaml
  importance: 2
  description: |
    Line numbers, the text of an item and text of surrounding lines
    can be grabbed from returned YAML objects - using .start_line,
    .end_line, lines(), lines_before(x) and lines_after(x).
  preconditions:
    yaml_snippet: |
      y: p
      # Some comment
          
      a: |
        x

      # Another comment
      b: y
      c: a

      d: b
      
    setup: |
      from strictyaml import Map, Str, YAMLValidationError, load

      schema = Map({"y": Str(), "a": Str(), "b": Str(), "c": Str(), "d": Str()})
      
      snippet = load(yaml_snippet, schema)

  variations:
    Start line includes previous comment:
      preconditions:
        code: |
          snippet["a"].start_line, snippet["d"].start_line
      scenario:
        - Should be equal to: (2, 9)

    End line includes comment:
      preconditions:
        code: |
          snippet["a"].end_line , snippet["d"].end_line
      scenario:
        - Should be equal to: (6, 10)
  
    Start line of key:
      preconditions:
        code: snippet.keys()[1].start_line
      scenario:
        - Should be equal to: 2

    Start and end line of all YAML:
      preconditions:
        code: snippet.start_line, snippet.end_line
      scenario:
        - Should be equal to: (1, 10)
        
    Lines before:
      preconditions:
        code: |
          snippet['a'].lines_before(1)
      scenario:
        - Should be equal to: |
            "y: p"

    Lines after:
      preconditions:
        code: |
         snippet['a'].lines_after(4)
      scenario:
        - Should be equal to: |
            "b: y\nc: a\n\nd: b"

    Relevant lines:
      preconditions:
        modified_yaml_snippet: |
          # Some comment
          a: |
            x

          # Another comment
        code: |
          load(yaml_snippet, schema)['a'].lines()
      scenario:
        - Should be equal to: modified_yaml_snippet.strip()

Start line of YAML with list:
  based on: strictyaml
  preconditions:
    yaml_snippet: |
      a:
        b:
        - 1
        # comment
        - 2
        - 3
        - 4
    setup: |
      from strictyaml import load
    code: |
      load(yaml_snippet)['a']['b'][1].start_line, load(yaml_snippet)['a']['b'][1].end_line
  scenario:
    - Should be equal to: (4, 5)
