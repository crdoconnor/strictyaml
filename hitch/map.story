Normal Map:
  based on: strictyaml
  importance: 3
  description: |
    Mappings of one value to another are represented by : in YAML
    and parsed as python dicts.
    
    Using StrictYAML's 'Map' you can validate that a mapping
    contains the right keys and the right *type* of values.
    
    Note: for mappings where you don't know the exact names of
    the keys in advance but you do know the type, use MapPattern.
  scenario:
    - Run command: |
        from strictyaml import Map, Int, load

        schema = Map({"a": Int(), "b": Int(), "c": Int()})

        schema_2 = Map({u"â": Int(), "b": Int(), "c": Int()})

    - Variable:
        name: onekeymap
        value: 'x: 1'

    - Assert True: |
        str(load(onekeymap, Map({"x": Int()})).data) == "{'x': 1}"

    - Variable:
        name: valid_mapping_2
        value: |
          â: 1
          b: 2
          c: 3

    - Assert True: |
        load(valid_mapping_2, schema_2)[u'â'] == 1

    - Variable:
        name: valid_mapping_1
        value: |
          â: 1
          b: 2
          c: 3

    - Assert Exception:
        command: load(valid_mapping_1, schema_2)['keynotfound']
        exception: keynotfound

    - Assert Exception:
        command: load(valid_mapping_1, schema_2).text
        exception: is a mapping, has no text value.

    - Variable:
        name: invalid_sequence_1
        value: |
          a: 1
          b: 2
          â: 3

    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'â'
            in "<unicode string>", line 3, column 1:
              "\xE2": '3'
              ^ (line: 3)

    - Variable:
        name: invalid_sequence_2
        value: |
          - 1
          - 2
          - 3

    - Assert Exception:
        command: load(invalid_sequence_2, schema)
        exception: |
          when expecting a mapping
            in "<unicode string>", line 1, column 1:
              - '1'
               ^ (line: 1)
          found non-mapping
            in "<unicode string>", line 3, column 1:
              - '3'
              ^ (line: 3)

    - Variable:
        name: invalid_sequence_3
        value: |
          a: 1
          b: 2
          c: 3
          d: 4

    - Assert Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'd'
            in "<unicode string>", line 4, column 1:
              d: '4'
              ^ (line: 4)
