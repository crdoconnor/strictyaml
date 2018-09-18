Sequence/list validator (Seq):
  docs: compound/sequences
  based on: strictyaml
  importance: 5
  description: |
    Sequences in YAML are denoted by a series of dashes ('-')
    and parsed as a list in python.

    Validating sequences of a particular type can be done with
    the Seq validator, specifying the type.

    See also UniqueSeq and FixedSeq for other types of sequence
    validation.
  given:
    yaml_snippet: |
      - 1
      - 2
      - 3
    setup: |
      from strictyaml import Seq, Str, Int, load
      from ensure import Ensure
  variations:
    Valid Parsed:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, Seq(Str()))).equals(["1", "2", "3", ])

    Is sequence:
      steps:
      - Run: |
          assert load(yaml_snippet, Seq(Str())).is_sequence()

    Iterator:
      steps:
      - Run: |
          assert [x for x in load(yaml_snippet, Seq(Str()))] == ["1", "2", "3"]

    .text is nonsensical:
      given:
        yaml_snippet: |
          - â
          - 2
          - 3
      steps:
      - Run:
          code: load(yaml_snippet, Seq(Str())).text
          raises:
            type:
              in python 2: exceptions.TypeError
              in python 3: builtins.TypeError
            message:
              in python 2: YAML([u'\xe2', '2', '3']) is a sequence, has no text value.
              in python 3: YAML(['â', '2', '3']) is a sequence, has no text value.

    Invalid mapping instead:
      given:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
      steps:
      - Run:
          code: load(yaml_snippet, Seq(Str()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a sequence
                in "<unicode string>", line 1, column 1:
                  a: '1'
                   ^ (line: 1)
              found a mapping
                in "<unicode string>", line 3, column 1:
                  c: '3'
                  ^ (line: 3)
    Invalid nested structure instead:
      given:
        yaml_snippet: |
          - 2
          - 3
          - a:
            - 1
            - 2
      steps:
      - Run:
          code: load(yaml_snippet, Seq(Str()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a str
                in "<unicode string>", line 3, column 1:
                  - a:
                  ^ (line: 3)
              found a mapping
                in "<unicode string>", line 5, column 1:
                    - '2'
                  ^ (line: 5)
    Invalid item in sequence:
      given:
        yaml_snippet: |
          - 1.1
          - 1.2
      steps:
      - Run:
          code: load(yaml_snippet, Seq(Int()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found an arbitrary number
                in "<unicode string>", line 1, column 1:
                  - '1.1'
                   ^ (line: 1)
    One invalid item in sequence:
      given:
        yaml_snippet: |
          - 1
          - 2
          - 3.4
      steps:
      - Run:
          code: load(yaml_snippet, Seq(Int()))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting an integer
              found an arbitrary number
                in "<unicode string>", line 3, column 1:
                  - '3.4'
                  ^ (line: 3)

Modify nested sequence:
  based on: strictyaml
  given:
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

      yaml['a'] = ['b', 'c', 'd']
      yaml['a'][1] = 'x'
  steps:
  - Run:
      code: print(yaml.as_yaml())
      will output: |-
        a:
        - b
        - x
        - d
        b: 2
        c: 3
