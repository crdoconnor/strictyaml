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
  scenario:
    - Code: |
        from strictyaml import Seq, Str, Int, load

    - Variable:
        name: valid_sequence
        value: |
          - 1
          - 2
          - 3

    - Returns True: load(valid_sequence, Seq(Str())) == ["1", "2", "3", ]

    - Returns True: load(valid_sequence, Seq(Str())).is_sequence()

    - Raises Exception:
        command: load(valid_sequence, Seq(Str())).text
        exception: is a sequence, has no text value.

    - Variable:
        name: invalid_sequence_1
        value: |
          a: 1
          b: 2
          c: 3

    - Raises Exception:
        command: load(invalid_sequence_1, Seq(Str()))
        exception: |
          when expecting a sequence
            in "<unicode string>", line 1, column 1:
              a: '1'
               ^ (line: 1)
          found non-sequence
            in "<unicode string>", line 3, column 1:
              c: '3'
              ^ (line: 3)

    - Variable:
        name: invalid_sequence_2
        value: |
          - 2
          - 3
          - a:
            - 1
            - 2

    - Raises Exception:
        command: load(invalid_sequence_2, Seq(Str()))
        exception: |
          when expecting a str
            in "<unicode string>", line 3, column 1:
              - a:
              ^ (line: 3)
          found mapping/sequence
            in "<unicode string>", line 5, column 1:
                - '2'
              ^ (line: 5)

    - Variable:
        name: invalid_sequence_3
        value: |
          - 1.1
          - 1.2

    - Raises Exception:
        command: load(invalid_sequence_3, Seq(Int()))
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 1, column 1:
              - '1.1'
               ^ (line: 1)

    - Variable:
        name: invalid_sequence_4
        value: |
          - 1
          - 2
          - 3.4

    - Raises Exception:
        command: load(invalid_sequence_4, Seq(Int()))
        exception: |
          when expecting an integer
          found non-integer
            in "<unicode string>", line 3, column 1:
              - '3.4'
              ^ (line: 3)
