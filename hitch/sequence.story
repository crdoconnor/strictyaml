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
    yaml_snippet: |
      - 1
      - 2
      - 3
    setup: |
      from strictyaml import Seq, Str, Int, load
      from ensure import Ensure
  variations:
    Valid Parsed:
      scenario:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Seq(Str()))).equals(["1", "2", "3", ])

    Is sequence:
      scenario:
      - Run:
          code: |
            assert load(yaml_snippet, Seq(Str())).is_sequence()

    .text is nonsensical:
      scenario:
      - Run:
          code: load(yaml_snippet, Seq(Str())).text
          raises:
            type:
              in python 2: exceptions.TypeError
              in python 3: builtins.TypeError
            message:
              in python 2: YAML([u'1', u'2', u'3']) is a sequence, has no text value.
              in python 3: YAML(['1', '2', '3']) is a sequence, has no text value.

    Invalid mapping instead:
      preconditions:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
      scenario:
      - Run:
          code: load(yaml_snippet, Seq(Str()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a sequence
                in "<unicode string>", line 1, column 1:
                  a: '1'
                   ^ (line: 1)
              found non-sequence
                in "<unicode string>", line 3, column 1:
                  c: '3'
                  ^ (line: 3)
    Invalid nested mapping instead:
      preconditions:
        yaml_snippet: |
          - 2
          - 3
          - a:
            - 1
            - 2
      scenario:
      - Run:
          code: load(yaml_snippet, Seq(Str()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a str
                in "<unicode string>", line 3, column 1:
                  - a:
                  ^ (line: 3)
              found mapping/sequence
                in "<unicode string>", line 5, column 1:
                    - '2'
                  ^ (line: 5)

    Invalid item in sequence:
      preconditions:
        yaml_snippet: |
          - 1.1
          - 1.2
      scenario:
      - Run:
          code: load(yaml_snippet, Seq(Int()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found non-integer
                in "<unicode string>", line 1, column 1:
                  - '1.1'
                   ^ (line: 1)
    One invalid item in sequence:
      preconditions:
        yaml_snippet: |
          - 1
          - 2
          - 3.4
      scenario:
      - Run:
          code: load(yaml_snippet, Seq(Int()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found non-integer
                in "<unicode string>", line 3, column 1:
                  - '3.4'
                  ^ (line: 3)

Modify nested sequence:
  based on: strictyaml
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
      yaml['a'][1] = 'x'
  scenario:
  - Run:
      code: print(yaml.as_yaml())
      will output: |-
        a:
        - b
        - x
        - d
        b: 2
        c: 3
