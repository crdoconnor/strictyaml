Get line numbers of YAML elements:
  based on: strictyaml
  docs: howto/what-line
  description: |
    Line numbers, the text of an item and text of surrounding lines
    can be grabbed from returned YAML objects - using .start_line,
    .end_line, lines(), lines_before(x) and lines_after(x).
  given:
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
    If there is preceding comment for an item the start line includes it:
      steps:
      - Run:
          code: |
            Ensure(snippet["a"].start_line).equals(3)
            Ensure(snippet["d"].start_line).equals(9)

    If there is a trailing comment the end line includes it:
      steps:
      - Run:
          code: |
            Ensure(snippet["a"].end_line).equals(6)
            Ensure(snippet["d"].end_line).equals(10)

    You can grab the start line of a key:
      steps:
      - Run:
          code: |
            Ensure(snippet.keys()[1].start_line).equals(3)

    Start line and end line of whole snippet:
      steps:
      - Run:
          code: |
            Ensure(snippet.start_line).equals(1)
            Ensure(snippet.end_line).equals(10)

    Grabbing a line before an item:
      steps:
      - Run:
          code: |
            Ensure(snippet['a'].lines_before(1)).equals("# Some comment")

    Grabbing a line after an item:
      steps:
      - Run:
          code: |
            Ensure(snippet['a'].lines_after(4)).equals("b: y\nc: a\n\nd: b")

    Grabbing the lines of an item including surrounding comments:
      steps:
      - Run:
          code: |
            print(load(yaml_snippet, schema)['a'].lines())
          will output: |-
            a: |
              x

            # Another comment

Start line of YAML with list:
  based on: strictyaml
  description: |
    Actually, this should probably be 6, not 4. This is likely a
    bug in ruamel.yaml however.

    TODO: Come back to this test.
  given:
    yaml_snippet: |
      a:
        b:
        - 1
        # comment
        # second comment
        - 2
        - 3
        - 4
    setup: |
      from strictyaml import load
      from ensure import Ensure
  steps:
  - Run:
      code: |-
        Ensure(load(yaml_snippet)['a']['b'][1].start_line).equals(4)
        Ensure(load(yaml_snippet)['a']['b'][1].end_line).equals(4)
