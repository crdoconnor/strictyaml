Floating point numbers (Float):
  docs: scalar/float
  based on: strictyaml
  description: |
    StrictYAML parses to a YAML object representing
    a decimal - e.g. YAML(1.0000000000000001)

    To get a python float literal, use .data.

    Parsing and validating as a Decimal is best for
    values which require precision, but float is better
    for values for which precision is not required.
  given:
    setup: |
      from math import isnan, isinf

      from strictyaml import Map, MapPattern, Str, Float, Bool, load, as_document
      from collections import OrderedDict
      from ensure import Ensure

      schema = Map({"a": Float(), "b": Float()})

    yaml_snippet: |
      a: 1.00000000000000000001
      b: 5.4135
  variations:
    Use .data to get float type:
      steps:
      - Run:
          code: |
            Ensure(type(load(yaml_snippet, schema)["a"].data)).equals(float)

    Equal to equivalent float which is different number:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals({"a": 1.0, "b": 5.4135})

    Cast to str:
      steps:
      - Run:
          code: |
            Ensure(str(load(yaml_snippet, schema)["a"])).equals("1.0")

    Cast to float:
      steps:
      - Run:
          code: |
            Ensure(float(load(yaml_snippet, schema)["a"])).equals(1.0)

    Greater than:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["a"] > 0).is_true()

    Less than:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["a"] < 0).is_false()

    Has NaN values:
      given:
        yaml_snippet: |
          a: nan
          b: .NaN
      steps:
        - Run:
            code: |
              Ensure(isnan(load(yaml_snippet, schema)["a"].data)).is_true()
              Ensure(isnan(load(yaml_snippet, schema)["b"].data)).is_true()

    Has infinity values:
      given:
        yaml_snippet: |
          a: -.Inf
          b: INF
      steps:
        - Run:
            code: |
              Ensure(isinf(load(yaml_snippet, schema)["a"].data)).is_true()
              Ensure(isinf(load(yaml_snippet, schema)["b"].data)).is_true()

    Has underscores:
      given:
        yaml_snippet: |
          a: 10_000_000.5
          b: 10_0_0.2_5
      steps:
        - Run:
            code: |
              Ensure(load(yaml_snippet, schema).data).equals({"a": 10000000.5, "b": 1000.25})

    Cannot cast to bool:
      steps:
      - Run:
          code: bool(load(yaml_snippet, schema)['a'])
          raises:
            message: |-
              Cannot cast 'YAML(1.0)' to bool.
              Use bool(yamlobj.data) or bool(yamlobj.text) instead.

    Cannot parse non-float:
      given:
        yaml_snippet: |
          a: string
          b: 2
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a float
              found arbitrary text
                in "<unicode string>", line 1, column 1:
                  a: string
                   ^ (line: 1)

    Serialize successfully:
      steps:
      - Run:
          code: print(as_document(OrderedDict([("a", 3.5), ("b", "2.1")]), schema).as_yaml())
          will output: |-
            a: 3.5
            b: 2.1

    Serialize successfully with NaN:
      steps:
      - Run:
          code: print(as_document(OrderedDict([("a", 3.5), ("b", float("nan"))]), schema).as_yaml())
          will output: |-
            a: 3.5
            b: nan

    Serialize successfully with infinity:
      steps:
        - Run:
            code: print(as_document(OrderedDict([("a", float("inf")), ("b", float("-inf"))]), schema).as_yaml())
            will output: |-
              a: inf
              b: -inf

    Serialization failure:
      steps:
      - Run:
          code: as_document(OrderedDict([("a", "x"), ("b", "2.1")]), schema)
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: when expecting a float, got 'x'

    Float as key:
      steps:
      - Run:
          code: |
            document = as_document(OrderedDict([("3.5", "a"), ("2.1", "c")]), MapPattern(Float(), Str()))
            print(document.data[3.5])
            print(document.data[2.1])
          will output: |-
            a
            c

    Float or bool:
      steps:
      - Run:
          code: |
            document = as_document({"a": True}, Map({"a": Float() | Bool()}))
            print(document.as_yaml())
          will output: |-
            a: yes
