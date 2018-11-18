Parsing strings (Str):
  docs: scalar/string
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object, not
    the value directly to give you more flexibility
    and control over what you can do with the YAML.

    This is what that can object can do - in most
    cases if parsed as a string, it will behave in
    the same way.
  given:
    setup: |
      from strictyaml import Str, Map, load
      from ensure import Ensure

      schema = Map({"a": Str(), "b": Str(), "c": Str(), "d": Str()})

      parsed = load(yaml_snippet, schema)
    yaml_snippet: |
      a: 1
      b: yes
      c: â string
      d: |
        multiline string
  variations:
    Parses correctly:
      steps:
      - Run:
          code: |
            Ensure(parsed).equals(
                {"a": "1", "b": "yes", "c": u"â string", "d": "multiline string\n"}
            )

    Dict lookup cast to string:
      steps:
      - Run:
          code: Ensure(str(parsed["a"])).equals("1")

    Dict lookup cast to int:
      steps:
      - Run:
          code: |
            Ensure(int(parsed["a"])).equals(1)

    Dict lookup cast to bool impossible:
      steps:
      - Run:
          code: bool(parsed["a"])
          raises:
            message: |-
              Cannot cast 'YAML(1)' to bool.
              Use bool(yamlobj.data) or bool(yamlobj.text) instead.

