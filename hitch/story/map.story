Mappings with defined keys (Map):
  docs: compound/mapping
  based on: strictyaml
  description: |
    Mappings of one value to another are represented by : in YAML
    and parsed as python dicts.

    Using StrictYAML's 'Map' you can validate that a mapping
    contains the right keys and the right *type* of values.

    Note: for mappings where you don't know the exact names of
    the keys in advance but you do know the type, use MapPattern.
  given:
    setup: |
      from collections import OrderedDict
      from strictyaml import Map, Int, load, as_document
      from collections import OrderedDict
      from ensure import Ensure

      schema = Map({"a": Int(), "b": Int(), "c": Int()})

      schema_2 = Map({u"â": Int(), "b": Int(), "c": Int()})
    yaml_snippet: |
      â: 1
      b: 2
      c: 3

  variations:
    one key mapping:
      given:
        yaml_snippet: 'x: 1'
      steps:
      - Run: |
          Ensure(load(yaml_snippet, Map({"x": Int()})).data).equals(OrderedDict([('x', 1)]))

    key value:
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema_2)[u'â']).equals(1)

    get item key not found:
      steps:
      - Run:
          code: load(yaml_snippet, schema_2)['keynotfound']
          raises:
            message: "'keynotfound'"

    cannot use .text:
      steps:
      - Run:
          code: load(yaml_snippet, schema_2).text
          raises:
            type:
              in python 3: builtins.TypeError
              in python 2: exceptions.TypeError
            message:
              in python 3: "YAML({'â': 1, 'b': 2, 'c': 3}) is a mapping, has no text value."
              in python 2: "YAML({u'\\xe2': 1, 'b': 2, 'c': 3}) is a mapping, has no text value."

    parse snippet where key is not found in schema:
      given:
        yaml_snippet: |
          a: 1
          b: 2
          â: 3 
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              unexpected key not in schema 'â'
                in "<unicode string>", line 3, column 1:
                  "\xE2": '3'
                  ^ (line: 3)

    sequence not expected when parsing:
      given:
        yaml_snippet: |
          - 1
          - 2
          - 3 
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a mapping
                in "<unicode string>", line 1, column 1:
                  - '1'
                   ^ (line: 1)
              found a sequence
                in "<unicode string>", line 3, column 1:
                  - '3'
                  ^ (line: 3)

    List not expected when serializing:
      steps:
      - Run:
          code: as_document([1, 2, 3], schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: Expected a dict, found '[1, 2, 3]'

    Empty dict not valid when serializing:
      steps:
      - Run:
          code: as_document({}, schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: "Expected a non-empty dict, found an empty dict.\nUse EmptyDict\
              \ validator to serialize empty dicts."
    Unexpected key:
      given:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
          d: 4
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              unexpected key not in schema 'd'
                in "<unicode string>", line 4, column 1:
                  d: '4'
                  ^ (line: 4)


    required key not found:
      given:
        yaml_snippet: |
          a: 1
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              required key(s) 'b', 'c' not found
                in "<unicode string>", line 1, column 1:
                  a: '1'
                   ^ (line: 1)



    iterator:
      given:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
      steps:
      - Run: |
          assert [item for item in load(yaml_snippet, schema)] == ["a", "b", "c"]

    serialize:
      steps:
      - Run: |
          assert as_document(OrderedDict([(u"â", 1), ("b", 2), ("c", 3)]), schema_2).as_yaml() == yaml_snippet
