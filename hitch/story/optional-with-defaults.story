Optional keys with defaults (Map/Optional):
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
      from strictyaml import Map, Int, Str, Bool, EmptyNone, Optional, load, as_document
      from collections import OrderedDict
      from ensure import Ensure

      schema = Map({"a": Int(), Optional("b", default=False): Bool(), })
  variations:
    When parsed the result will include the optional value:
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema).data).equals(OrderedDict([("a", 1), ("b", False)]))

    If parsed and then output to YAML again the default data won't be there:
      steps:
      - Run:
          code: print(load(yaml_snippet, schema).as_yaml())
          will output: |-
            a: 1

    When default data is output to YAML it is removed:
      steps:
      - Run:
          code: |
            print(as_document({"a": 1, "b": False}, schema).as_yaml())
          will output: |-
            a: 1

    Include defaults when recording the effective configuration:
      steps:
      - Run:
          code: |
            configuration = load(yaml_snippet, schema)
            print(configuration.as_yaml(include_defaults=True))
            assert configuration.as_yaml() == yaml_snippet
          will output: |-
            a: 1
            b: no

    Include defaults when serializing Python data:
      steps:
      - Run:
          code: |
            print(as_document({"a": 1, "b": False}, schema).as_yaml(include_defaults=True))
          will output: |-
            a: 1
            b: no

    Include defaults in nested mappings and sequence items:
      steps:
      - Run:
          code: |
            from strictyaml import Seq
            nested = load("items:\n- a: 1\n", Map({"items": Seq(schema)}))
            print(nested.as_yaml(include_defaults=True))
          will output: |-
            items:
            - a: 1
              b: no
    
    When you want a key to stay and default to None:
      steps:
      - Run:
          code: |
            schema = Map({"a": Int(), Optional("b", default=None, drop_if_none=False): EmptyNone() | Bool(), })
            Ensure(load(yaml_snippet, schema).data).equals(OrderedDict([("a", 1), ("b", None)]))


Optional keys with bad defaults:
  based on: Optional keys with defaults (Map/Optional)
  steps:
  - Run:
      code: |
        Map({"a": Int(), Optional("b", default="nonsense"): Bool(), })
      raises:
        type: strictyaml.exceptions.InvalidOptionalDefault
        message: "Optional default for 'b' failed validation:\n  Not a boolean"


Optional keys revalidation bug:
  based on: Optional keys with defaults (Map/Optional)
  given:
    yaml_snippet: |
      content:
        subitem:
          a: 1
  steps:
  - Run:
      code: |
        from strictyaml import MapPattern, Any

        loose_schema = Map({"content": Any()})
        strict_schema = Map({"subitem": Map({"a": Int(), Optional("b", default=False): Bool()})})

        myyaml = load(yaml_snippet, loose_schema)
        myyaml['content'].revalidate(strict_schema)
        assert myyaml.data == {"content": {"subitem": {"a": 1, "b": False}}}, myyaml.data
        print(myyaml.data.__repr__())
      will output: "{'content': {'subitem': {'a': 1, 'b': False}}}"
