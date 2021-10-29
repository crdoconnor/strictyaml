Mappings combining defined and undefined keys (MapCombined):
  based on: strictyaml
  experimental: yes
  description: |
    See https://github.com/crdoconnor/strictyaml/issues/148#issuecomment-861007657
  given:
    setup: |
      from strictyaml import Any, Int, MapCombined, Optional, Str, load
      from ensure import Ensure

      schema = MapCombined({
        "required": Str(),
        Optional("foo"): Int(),
        Str(): Any(),
      })
    yaml_snippet: |
      required: Hello World
      foo: 42
      bar: 42
  steps:
  - Run: |
      Ensure(load(yaml_snippet, schema).data).equals(
          {
              "name": "Hello World",
              "foo": 42,
              "bar": "42",
          }
      )
