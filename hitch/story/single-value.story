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
      from ensure import Ensure
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
            Ensure(load("1", Str())).equals("1")

    Int of 1:
      steps:
      - Run:
          code: |
            Ensure(load("1", Int())).equals(1)

    Empty value parsed as blank string by default:
      steps:
      - Run:
          code: |
            Ensure(load("x:")).equals({"x": ""})

    Empty document parsed as blank string by default:
      steps:
      - Run:
          code: |
            Ensure(load("", Str())).equals("")

    Null parsed as string null by default:
      steps:
      - Run:
          code: |
            Ensure(load("null: null")).equals({"null": "null"})

    #Single value with comment:
      #steps:
      #- Run:
          #code: |
            #Ensure(load("# ought not to be parsed\nstring")).equals("string")
