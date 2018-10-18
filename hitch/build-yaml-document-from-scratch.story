Build a YAML document from scratch in code:
  docs: howto/build-yaml-document
  experimental: yes
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

    Start line:
      steps:
      - Run:
          code: |
            Ensure(yaml.start_line).equals(1)


Build document from invalid type:
  based on: strictyaml
  about: |
    YAML documents should only be buildable from dicts
    lists, strings, numbers and booleans.

    All other types should raise an exception.
  given:
    setup: |
      from strictyaml import as_document

      class RandomClass(object):
          def __repr__(self):
              return 'some random object'

  variations:
    non-string:
      steps:
      - run:
          code: |
            as_document({"x": RandomClass()})
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: |-
              'some random object' is not a string


    empty dict:
      steps:
      - run:
          code: |
            as_document({'hello': {}})
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: Empty dicts are not serializable to StrictYAML unless schema
              is used.
    empty list:
      steps:
      - run:
          code: |
            as_document({'hello': []})
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: Empty lists are not serializable to StrictYAML unless schema
              is used.
