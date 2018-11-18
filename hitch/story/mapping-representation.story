Using a YAML object of a parsed mapping:
  docs: compound/mapping-yaml-object
  based on: strictyaml
  description: |
    When a YAML document with mappings is parsed, it is not parsed
    as a dict but as a YAML object which behaves very similarly to
    a dict, but with some extra capabilities.

    You can use .items(), .keys(), .values(), look up items with
    square bracket notation, .get(key, with_default_if_nonexistent)
    and use "x in y" notation to determine key membership.

    To retrieve the equivalent dict (containing just other dicts, lists
    and strings/ints/etc.) use .data.
  given:
    setup: |
      from strictyaml import Map, Int, load
      from ensure import Ensure

      schema = Map({"a": Int(), "b": Int(), "c": Int()})
    yaml_snippet: |
      a: 1
      b: 2
      c: 3
  variations:
    .is_mapping():
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).is_mapping()).is_true()

    Equivalence with equivalent plain dict:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": 2, "c": 3})

    .items():
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).items()).equals([("a", 1), ("b", 2), ("c", 3)])

    Use in to detect presence of a key:
      steps:
      - Run:
          code: |
            Ensure("a" in load(yaml_snippet, schema)).is_true()

    .values():
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).values()).equals([1, 2, 3])

    .keys():
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).keys()).equals(["a", "b", "c"])
            
    Key lookup:
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            Ensure(yaml[yaml.keys()[0]]).equals(1)

    Dict lookup:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["a"]).equals(1)

    .get():
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).get("a")).equals(1)

    .get() nonexistent:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).get("nonexistent")).equals(None)

    len():
      steps:
      - Run:
          code: |
            Ensure(len(load(yaml_snippet, schema))).equals(3)
