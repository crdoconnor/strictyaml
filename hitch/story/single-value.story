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
      from strictyaml import Str, Int, Bool, load
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

    Comments are not part of a standalone scalar:
      steps:
      - Run:
          code: |
            for document in ["x # comment", "# before\nx", "'x' # comment", '"x" # comment']:
                assert load(document).data == "x"

    Plain scalar whitespace follows YAML parsing:
      steps:
      - Run:
          code: |
            assert load(" hello world ").data == "hello world"
            assert load("a\nb").data == "a b"

    Block scalar folding and chomping are retained:
      steps:
      - Run:
          code: |
            assert load("|-\n  a\n  b\n").data == "a\nb"
            assert load(">-\n  a\n  b\n").data == "a b"

    Markers and comments do not interfere with scalar validators:
      steps:
      - Run:
          code: |
            assert load("42 # count", Int()).data == 42
            assert load("---\ntrue\n", Bool()).data is True
            assert load("---\ntrue # flag\n").data == "true"

    Empty and comment-only documents produce blank strings:
      steps:
      - Run:
          code: |
            for document in ["", " \n", "# only a comment", "---\n", "---\n# comment\n"]:
                assert load(document).data == ""

    Hash characters in scalar values are retained:
      steps:
      - Run:
          code: |
            assert load("x#fragment").data == "x#fragment"
            assert load("'x # literal' # comment").data == "x # literal"

    Parsed scalar values survive serialization:
      steps:
      - Run:
          code: |
            value = load("x # comment")
            assert load(value.as_yaml()).data == "x"
            assert load("key: value # comment").data == {"key": "value"}
            assert load("- a # comment\n- b\n").data == ["a", "b"]
