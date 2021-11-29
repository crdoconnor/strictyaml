Dirty load:
  docs: restrictions/loading-dirty-yaml
  based on: strictyaml
  description: |
    StrictYAML refuses to parse flow style and node anchors
    by default, but since there have since been
    [some requests](https://github.com/crdoconnor/strictyaml/issues/38)
    to parse flow style, this now allowed with the "dirty_load" method.
    If allow_flow_style is True, Map indentation is not checked for
    consistency, as the indentation level is dependent on the map key length.
  given:
    setup: |
      from strictyaml import Map, Int, MapPattern, Seq, Str, Any, dirty_load

      schema = Map({"foo": Map({"a": Any(), "b": Any(), "c": Any()}), "y": MapPattern(Str(), Str()), "z": Seq(Str())})
  variations:
    Flow style mapping:
      given:
        yaml_snippet: |
          foo: { a: 1, b: 2, c: 3 }
          y: {}
          z: []
      steps:
      - Run: |
          assert dirty_load(yaml_snippet, schema, allow_flow_style=True) == {"foo": {"a": "1", "b": "2", "c": "3"}, "y": {}, "z": []}
