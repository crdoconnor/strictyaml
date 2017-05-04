Normal Map:
  based on: strictyaml
  preconditions:
    files:
      onekeymap.yaml: |
        x: 1
      valid_mapping.yaml: |
        a: 1
        b: 2
        c: 3
      valid_mapping_2.yaml: |
        â: 1
        b: 2
        c: 3
      invalid_sequence_1.yaml: |
        a: 1
        b: 2
        â: 3
      invalid_sequence_2.yaml: |
        - 1
        - 2
        - 3
      invalid_sequence_3.yaml: |
        a: 1
        b: 2
        c: 3
        d: 4
  scenario:
    - Run command: |
        from strictyaml import Map, Int, YAMLValidationError, load

        schema = Map({"a": Int(), "b": Int(), "c": Int()})

        schema_2 = Map({u"â": Int(), "b": Int(), "c": Int()})

    - Assert True: |
        str(load(onekeymap, Map({"x": Int()})).data) == "{'x': 1}"

    - Assert True: |
        load(valid_mapping_2, schema_2)[u'â'] == 1

    - Assert Exception:
        command: load(valid_mapping, schema)['keynotfound']
        exception: keynotfound

    - Assert Exception:
        command: load(valid_mapping, schema).text
        exception: is a mapping, has no text value.

    - Assert Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'â'
            in "<unicode string>", line 3, column 1:
              "\xE2": '3'
              ^ (line: 3)

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

    - Assert Exception:
        command: load(invalid_sequence_3, schema)
        exception: |
          while parsing a mapping
          unexpected key not in schema 'd'
            in "<unicode string>", line 4, column 1:
              d: '4'
              ^ (line: 4)
