Build YAML document:
  docs: howto/build-yaml-document
  experimental: yes
  based on: strictyaml
  description: |
    YAML documents can be built from dicts and lists of
    scalar values.
  given:
    setup: |
      from ensure import Ensure
      from strictyaml import as_document
      from collections import OrderedDict

      # Can also use regular dict if an arbitrary ordering is ok
      yaml = as_document(OrderedDict(
          [("a", True), ("b", "hello"), ("c", [1, 2, 3])]
      ))
  variations:
    Then dump:
      steps:
      - Run:
          code: print(yaml.as_yaml())
          will output: |-
            a: yes
            b: hello
            c:
            - 1
            - 2
            - 3

    Start line:
      steps:
      - Run:
          code: |
            Ensure(yaml.start_line).equals(1)
