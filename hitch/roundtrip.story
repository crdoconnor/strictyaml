Roundtripped YAML:
  based on: strictyaml
  description: |
    Loaded YAML can be modified and dumped out again with
    comments preserved using .as_yaml().
    
    Note that due to some bugs in the library (ruamel.yaml)
    underlying StrictYAML, while the data parsed should
    be precisely the same, the exact syntax (newlines, comment
    locations, etc.) may not be identical.
  scenario:
    - Code: |
        from strictyaml import Map, MapPattern, Str, Seq, Int, load
        import difflib

        schema = Map({
            "a": Str(),
            "b": Map({"x": Int(), "y": Int()}),
            "c": Seq(MapPattern(Str(), Str())),
        })
    
    - Variable:
        name: commented_yaml
        value: |
          # Some comment
          
          a: â # value comment
          
          # Another comment
          b:
            x: 4
            y: 5
          c:
          - a: 1
          - b: 2
    
    - Returns True: |
        load(commented_yaml, schema).as_yaml() == commented_yaml

    - Code: |
        to_modify = load(commented_yaml, schema)

    - Code: |
        to_modify['b']['x'] = load('2')
        to_modify['c'][0]['a'] = load('3')

    - Raises Exception:
        command: |
          to_modify['b']['x'] = load('not an integer')
        exception: found non-integer

    - Variable:
        name: modified_commented_yaml
        value: |
          # Some comment
          
          a: â # value comment
          
          # Another comment
          b:
            y: 5
            x: 2
          c:
          - a: 3
          - b: 2

    - Should be equal:
        lhs: to_modify.as_yaml()
        rhs: modified_commented_yaml

    - Variable:
        name: with_integer
        value: |
          x: 1

    - Returns True: |
       load(with_integer, Map({"x": Int()})).as_yaml() == "x: 1\n"
