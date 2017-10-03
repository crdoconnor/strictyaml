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
      from ensure import Ensure

      schema = Map({"y": Str(), "a": Str(), "b": Str(), "c": Str(), "d": Str()})

      snippet = load(yaml_snippet, schema)

  variations:
    Start line includes previous comment:
      scenario:
      - Run: |
          Ensure(snippet["a"].start_line).equals(2)
          Ensure(snippet["d"].start_line).equals(9)

    End line includes comment:
      scenario:
      - Run: |
          Ensure(snippet["a"].end_line).equals(6)
          Ensure(snippet["d"].end_line).equals(10)

    Start line of key:
      scenario:
      - Run: |
          Ensure(snippet.keys()[1].start_line).equals(2)

    Start and end line of all YAML:
      scenario:
      - Run:
          code: |
            Ensure(snippet.start_line).equals(1)
            Ensure(snippet.end_line).equals(10)

    Lines before:
      scenario:
      - Run: |
          Ensure(snippet['a'].lines_before(1)).equals("y: p")

    Lines after:
      scenario:
      - Run: |
          Ensure(snippet['a'].lines_after(4)).equals("b: y\nc: a\n\nd: b")

    Relevant lines:
      scenario:
      - Run:
          code: |
            print(load(yaml_snippet, schema)['a'].lines())
          will output: |-
            # Some comment
            a: |
              x

            # Another comment

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
      from ensure import Ensure
  scenario:
  - Run:
      code: |-
        Ensure(load(yaml_snippet)['a']['b'][1].start_line).equals(4)
        Ensure(load(yaml_snippet)['a']['b'][1].end_line).equals(5)
