Dirty load:
  docs: restrictions/loading-dirty-yaml
  based on: strictyaml
  description: |
    StrictYAML refuses to parse flow style and node anchors
    by default, but since there have since been requests to parse
    flow style.
  given:
    setup: |
      from strictyaml import Map, Int, Any, dirty_load

      schema = Map({"x": Map({"a": Any(), "b": Any(), "c": Any()})})
  variations:
    Flow style mapping:
      given:
        yaml_snippet: |
          x: { a: 1, b: 2, c: 3 }
      steps:
      - Run: |
          assert dirty_load(yaml_snippet, schema, allow_flow_style=True) == {"x": {"a": "1", "b": "2", "c": "3"},}
