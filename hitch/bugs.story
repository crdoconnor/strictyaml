Revalidation with an or breaks lookup:
  based on: strictyaml
  given:
    yaml_snippet: |
      x:
        a: b
    setup: |
      from strictyaml import load, Any, Int, Str, Map
      loose_schema = Map({"x": Any()})
      strict_schema = Str() | Map({"a": Str()})
  steps:
  - run: |
      parsed = load(yaml_snippet, loose_schema)
      parsed['x'].revalidate(strict_schema)
      parsed['x']['a'] = "x"
      assert parsed['x']['a'] == "x"
