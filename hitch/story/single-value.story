Single value:
  based on: strictyaml
  description: |
    The minimal YAML document that is parsed by StrictYAML is
    a string of characters which parses by default to a string
    unless a scalar validator is used.

    Where standard YAML implicitly converts certain strings
    to other types, StrictYAML will only parse to strings
    unless otherwise directed.
  given:
    setup: |
      from strictyaml import Str, Int, load
  variations:
    Raise exception on None:
      steps:
      - Run:
          code: load(None, Str())
          raises:
            message: StrictYAML can only read a string of valid YAML.

    String of 1:
      steps:
      - Run:
          code: |
            assert load("1", Str()) == "1"

    Int of 1:
      steps:
      - Run:
          code: |
            assert load("1", Int()) == 1

    Empty value parsed as blank string by default:
      steps:
      - Run:
          code: |
            assert load("x:") == {"x": ""}

    Empty document parsed as blank string by default:
      steps:
      - Run:
          code: |
            assert load("", Str()) == ""

    Null parsed as string null by default:
      steps:
      - Run:
          code: |
            assert load("null: null") == {"null": "null"}

    #Single value with comment:
      #steps:
      #- Run:
          #code: |
            #assert load("# ought not to be parsed\nstring") == "string"
