Seq validator:
  based on: strictyaml
  importance: 5
  description: |
    Sequences in YAML are denoted by a series of dashes ('-')
    and parsed as a list in python.

    Validating sequences of a particular type can be done with
    the Seq validator, specifying the type.

    See also UniqueSeq and FixedSeq for other types of sequence
    validation.
  preconditions:
    setup: |
      from strictyaml import Seq, Str, Int, load

Valid Seq:
  based on: Seq validator
  preconditions:
    yaml_snippet: |
      - 1
      - 2
      - 3
  variations:
    Parsed:
      preconditions:
        code: |
          load(yaml_snippet, Seq(Str()))
      scenario:
      - Should be equal to: |
          ["1", "2", "3", ]
    Is sequence:
      preconditions:
        code: load(yaml_snippet, Seq(Str())).is_sequence()
      scenario:
      - Should be equal to: 'True'
    .text is nonsensical:
      preconditions:
        code: load(yaml_snippet, Seq(Str())).text
      scenario:
      - Raises exception:
          exception type:
            in python 2: exceptions.TypeError
            in python 3: builtins.TypeError
          message:
            in python 2: YAML([u'1', u'2', u'3']) is a sequence, has no text value.
            in python 3: YAML(['1', '2', '3']) is a sequence, has no text value.

Invalid Seq - Mapping instead:
  based on: Seq validator
  preconditions:
    yaml_snippet: |
      a: 1
      b: 2
      c: 3
    code: load(yaml_snippet, Seq(Str()))
  scenario:
  - Raises Exception:
      exception type: strictyaml.exceptions.YAMLValidationError
      message: |-
        when expecting a sequence
          in "<unicode string>", line 1, column 1:
            a: '1'
             ^ (line: 1)
        found non-sequence
          in "<unicode string>", line 3, column 1:
            c: '3'
            ^ (line: 3)

Invalid sequence - nested mapping instead:
  based on: Seq validator
  preconditions:
    yaml_snippet: |
      - 2
      - 3
      - a:
        - 1
        - 2
    code: load(yaml_snippet, Seq(Str()))
  scenario:
  - Raises Exception:
      exception type: strictyaml.exceptions.YAMLValidationError
      message: |-
        when expecting a str
          in "<unicode string>", line 3, column 1:
            - a:
            ^ (line: 3)
        found mapping/sequence
          in "<unicode string>", line 5, column 1:
              - '2'
            ^ (line: 5)

Invalid sequence - invalid item in sequence:
  based on: Seq validator
  preconditions:
    yaml_snippet: |
      - 1.1
      - 1.2
    code: load(yaml_snippet, Seq(Int()))
  scenario:
  - Raises exception:
      exception type: strictyaml.exceptions.YAMLValidationError
      message: |-
        when expecting an integer
        found non-integer
          in "<unicode string>", line 1, column 1:
            - '1.1'
             ^ (line: 1)

Invalid sequence - one invalid item in sequence:
  based on: Seq validator
  preconditions:
    yaml_snippet: |
      - 1
      - 2
      - 3.4
    code: load(yaml_snippet, Seq(Int()))
  scenario:
  - Raises exception:
      exception type: strictyaml.exceptions.YAMLValidationError
      message: |-
        when expecting an integer
        found non-integer
          in "<unicode string>", line 3, column 1:
            - '3.4'
            ^ (line: 3)
Modify nested sequence:
  based on: Seq validator
  preconditions:
    yaml_snippet: |
      a:
        - a
        - b
      b: 2
      c: 3
    setup: |
      from strictyaml import Map, Int, load, Seq, Str
      from collections import OrderedDict

      schema = Map({"a": Seq(Str()), "b": Int(), "c": Int()})

      yaml = load(yaml_snippet, schema)

      # Non-ordered dict would also work, but would yield an indeterminate order of keys
      yaml['a'] = ['b', 'c', 'd']
    code: |
      yaml.as_yaml()
    modified_yaml_snippet: |
      a:
      - b
      - c
      - d
      b: 2
      c: 3
  scenario:
  - Should be equal to: modified_yaml_snippet
