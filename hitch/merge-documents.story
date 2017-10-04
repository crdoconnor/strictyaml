Merge YAML documents:
  based on: strictyaml
  description: |
    Loaded YAML can be combined and dumped with the comments intact.
  preconditions:
    yaml_snippet_1: |
      # Some comment

      a: â # value comment

      # Another comment
      b:
        x: 4
        y: 5
      c:
      - a: 1
      - b: 2
    yaml_snippet_2: |
      x: 8

      # y is now 9
      y: 9
    setup: |
      from strictyaml import Map, MapPattern, Str, Seq, Int, load

      schema_1 = Map({
          "a": Str(),
          "b": Map({"x": Int(), "y": Int()}),
          "c": Seq(MapPattern(Str(), Str())),
      })

      schema_2 = Map({"x": Int(), "y": Int()})

      yaml_1 = load(yaml_snippet_1, schema_1)
      yaml_2 = load(yaml_snippet_2, schema_2)

      yaml_1['b'] = yaml_2
  scenario:
  - Run:
      code: print(yaml_1.as_yaml())
      will output: |-
        # Some comment

        a: â # value comment

        # Another comment
        b:
          x: 8

        # y is now 9
          y: 9
        c:
        - a: 1
        - b: 2
