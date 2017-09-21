Build YAML document:
  based on: strictyaml
  description: |
    YAML documents can be built from dicts and lists of
    scalar values.
  preconditions:
    yaml_snippet: |
      a: yes
      b: hello
      c:
      - 1
      - 2
      - 3
    setup: |
      from strictyaml import YAML
      from collections import OrderedDict

      # Can also use regular dict if an arbitrary ordering is ok
      yaml = YAML(OrderedDict(
          [("a", True), ("b", "hello"), ("c", [1, 2, 3])]
      ))
    code: yaml.as_yaml()
  scenario:
  - Should be equal to: yaml_snippet
