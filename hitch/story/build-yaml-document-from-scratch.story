Build a YAML document from scratch in code:
  docs: howto/build-yaml-document
  based on: strictyaml
  description: |
    YAML documents can be built from combinations of dicts,
    lists and strings if no schema is used.
  given:
    setup: |
      from ensure import Ensure
      from strictyaml import as_document
      from collections import OrderedDict

      # Can also use regular dict if an arbitrary ordering is ok
      yaml = as_document(OrderedDict(
          [(u"â", 'yes'), ("b", "hâllo"), ("c", ["1", "2", "3"])]
      ))
  variations:
    Then dump:
      steps:
      - Run:
          code: print(yaml.as_yaml())
          will output: |-
            â: yes
            b: hâllo
            c:
            - 1
            - 2
            - 3

    However, any type that is not a string, dict or list cannot be parsed without a schema:
      steps:
      - run:
          code: |
            class RandomClass(object):
                def __repr__(self):
                    return 'some random object'

            as_document({"x": RandomClass()})
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: |-
              'some random object' is not a string

    Empty dicts also cannot be serialized without a schema:
      steps:
      - run:
          code: |
            as_document({'hello': {}})
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: Empty dicts are not serializable to StrictYAML unless schema
              is used.

    Neither can lists:
      steps:
      - run:
          code: |
            as_document({'hello': []})
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: Empty lists are not serializable to StrictYAML unless schema
              is used.

    You can grab line numbers from the object that is serialized:
      steps:
      - Run:
          code: |
            Ensure(yaml.start_line).equals(1)
