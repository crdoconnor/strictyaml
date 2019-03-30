Mapping which can have varying structures (AlternateMaps):
  docs: compound/mapping
  based on: strictyaml
  description: |
    Using alternate maps you can validate different
    mapping structures according to one key.
    
    This feature was inspired by https://github.com/kinkerl
  given:
    setup: |
      from collections import OrderedDict
      from strictyaml import Map, Int, Str, AlternateMaps, load
      from ensure import Ensure

      schema = AlternateMaps(
          {
            "a": {"type": Str(), "helptext": Str()},
            "b": {"type": Str(), "min": Int(), "max": Int()},
          },
          key="type",
      )

  variations:
    example a:
      given:
        yaml_snippet: |
          type: a
          helptext: help
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema).data).equals(OrderedDict([('type', 'a'), ('helptext', 'help')]))
