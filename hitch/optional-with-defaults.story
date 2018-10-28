Optional keys with defaults (Map):
  docs: compound/optional-keys-with-defaults
  experimental: yes
  based on: strictyaml
  about: |
    Not every key in a YAML mapping will be required. If
    you use the "Optional('key')" validator with YAML,
    you can signal that a key/value pair is not required.
  given:
    yaml_snippet: |
      a: 1
    setup: |
      from strictyaml import Map, Int, Str, Bool, Optional, load, as_document
      from ensure import Ensure

      schema = Map({"a": Int(), Optional("b", default=False): Bool(), })
  variations:
    Duck typing the result:
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": False})

    Output to YAML:
      steps:
      - Run:
          code: print(load(yaml_snippet, schema).as_yaml())
          will output: |-
            a: 1

    Turning default data into documents:
      steps:
      - Run:
          code: |
            print(as_document({"a": 1, "b": False}, schema).as_yaml())
          will output: |-
            a: 1
