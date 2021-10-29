Mappings combining defined and undefined keys (MapCombined):
  docs: compound/map-combined
  based on: strictyaml
  experimental: yes
  description: |
    When you wish to support arbitrary optional keys in
    some mappings (i.e. to specify some required keys in
    the schema, but allow any additional ones on top of
    that), you use a MapCombined.

    See https://github.com/crdoconnor/strictyaml/issues/148#issuecomment-861007657
  given:
    setup: |
      from strictyaml import Any, Int, MapCombined, Optional, Str, load
      from ensure import Ensure

      schema = MapCombined(
        {
          "required": Str(),
          Optional("foo"): Int(),
        },
        Str(),
        Any(),
      )
  variations:
    "Optional is present":
      given:
        yaml_snippet: |
          required: Hello World
          foo: 42
          bar: 42
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema).data).equals(
              {
                  "required": "Hello World",
                  "foo": 42,
                  "bar": "42",
              }
          )
    "Optional is absent":
      given:
        yaml_snippet: |
          required: Hello World
          bar: 42
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema).data).equals(
              {
                  "required": "Hello World",
                  "bar": "42",
              }
          )
    "Multiple undefined":
      given:
        yaml_snippet: |
          required: Hello World
          bar: 42
          baz: forty two
      steps:
      - Run: |
          Ensure(load(yaml_snippet, schema).data).equals(
              {
                  "required": "Hello World",
                  "bar": "42",
                  "baz": "forty two",
              }
          )
    "Required is absent":
      given:
        yaml_snippet: |
          bar: 42
      steps:
      - Run:
          code:
            load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              required key(s) 'required' not found
                in "<unicode string>", line 1, column 1:
                  bar: '42'
                   ^ (line: 1)
    "Undefined of invalid type":
      given:
        setup: |
          from strictyaml import Any, Int, MapCombined, Optional, Str, load
          from ensure import Ensure

          schema = MapCombined(
            {
              "required": Str(),
            },
            Str(),
            Int(),
          )
        yaml_snippet: |
          required: Hello World
          bar: forty two
      steps:
      - Run:
          code:
            load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 2, column 1:
                  bar: forty two
                  ^ (line: 2)
    "Invalid key type":
      given:
        setup: |
          from strictyaml import Any, Int, MapCombined, Optional, Str, load
          from ensure import Ensure

          schema = MapCombined(
            {
              "1": Str(),
            },
            Int(),
            Str(),
          )
        yaml_snippet: |
          1: Hello World
          not_an_integer: 42
      steps:
      - Run:
          code:
            load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found arbitrary text
                in "<unicode string>", line 2, column 1:
                  not_an_integer: '42'
                  ^ (line: 2)
