Map:
  based on: strictyaml
  description: |
    When a YAML document with mappings is parsed, it is not parsed
    as a dict but as a YAML object which behaves very similarly to
    a dict, but also has some extra capabilities.

    You can use .items(), .keys(), .values(), look up items with
    square bracket notation, .get(key, with_default_if_nonexistent)
    and use "x in y" notation to determine key membership.

    To retrieve the equivalent dict (containing just other dicts, lists
    and strings/ints/etc.) use .data.
  preconditions:
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
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).is_mapping()).is_true()

    Equivalence with equivalent plain dict:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": 2, "c": 3})

    .items():
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).items()).equals([("a", 1), ("b", 2), ("c", 3)])

    Use in to detect presence of a key:
      scenario:
      - Run:
          code: |
            Ensure("a" in load(yaml_snippet, schema)).is_true()

    .values():
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).values()).equals([1, 2, 3])

    .keys():
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).keys()).equals(["a", "b", "c"])

    Dict lookup:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["a"]).equals(1)

    .get():
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).get("a")).equals(1)

    .get() nonexistent:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema).get("nonexistent")).equals(None)

    len():
      scenario:
      - Run:
          code: |
            Ensure(len(load(yaml_snippet, schema))).equals(3)
