Parsing comma separated items (CommaSeparated):
  docs: scalar/comma-separated
  based on: strictyaml
  description: |
    Comma-separated values can be validated and parsed
    using the CommaSeparated validator.

    Note that the space following the commas is stripped by
    default when parsed.
  given:
    setup: |
      from strictyaml import CommaSeparated, Int, Str, Map, load, as_document
      from ensure import Ensure

      int_schema = Map({"a": CommaSeparated(Int())})

      str_schema = Map({"a": CommaSeparated(Str())})
  variations:
    Parse as int:
      given:
        yaml_snippet: |
          a: 1, 2, 3
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, int_schema)).equals({"a": [1, 2, 3]})

    Parse as string:
      given:
        yaml_snippet: |
          a: 1, 2, 3
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, str_schema)).equals({"a": ["1", "2", "3"]})

    Parse empty comma separated string:
      given:
        yaml_snippet: |
          a: 
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, str_schema)).equals({"a": []})

    Invalid int comma separated sequence:
      given:
        yaml_snippet: |
          a: 1, x, 3
      steps:
      - Run:
          code: load(yaml_snippet, int_schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
                in "<unicode string>", line 2, column 1:
                  
                  ^ (line: 2)
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: 1, x, 3
                   ^ (line: 1)

    Serialize list to comma separated sequence:
      steps:
      - Run:
          code: |
            print(as_document({"a": [1, 2, 3]}, int_schema).as_yaml())
          will output: 'a: 1, 2, 3'

    Serialize valid string to comma separated sequence:
      steps:
      - Run:
          code: |
            print(as_document({"a": "1,2,3"}, int_schema).as_yaml())
          will output: 'a: 1,2,3'

    Serialize spaced string to comma separated sequence:
      steps:
      - Run:
          code: |
            print(as_document({"a": "1, 2, 3"}, int_schema).as_yaml())
          will output: 'a: 1, 2, 3'

    Whitespace around items is consistent when reading and writing:
      steps:
      - Run:
          code: |
            for value in ("1,   2", "1 ,  2"):
                Ensure(load("a: " + value, int_schema).data).equals({"a": [1, 2]})
                Ensure(as_document({"a": value}, int_schema).data).equals({"a": [1, 2]})

    Empty string items can be parsed and serialized:
      steps:
      - Run:
          code: |
            Ensure(load("a: first,,last,", str_schema).data).equals({"a": ["first", "", "last", ""]})
            Ensure(as_document({"a": ["first", "", "last"]}, str_schema).data).equals({"a": ["first", "", "last"]})

    Empty integer item is rejected when serializing:
      steps:
      - Run:
          code: |
            as_document({"a": "1,,3"}, int_schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: "'' not an integer."

    Serialize empty list to comma separated sequence:
      steps:
      - Run:
          code: |
            print(as_document({"a": []}, int_schema).as_yaml())
          will output: 'a:'

    Serialize invalid string to comma separated sequence:
      steps:
      - Run:
          code: |
            print(as_document({"a": "1,x,3"}, int_schema).as_yaml())
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: "'x' not an integer."

    Attempt to serialize neither list nor string raises exception:
      steps:
      - Run:
          code: |
            as_document({"a": 1}, int_schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: expected string or list, got '1' of type 'int'
