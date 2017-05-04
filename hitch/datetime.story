Datetime validation:
  based on: strictyaml
  description: |
    Datetime validator parses using the python-dateutil library and
    returns a python datetime object.
  preconditions:
    files:
      valid_sequence.yaml: |
        date: 2016-10-22
        datetime1: 2016-10-22T14:23:12+00:00
        datetime2: 2016-10-22T14:23:12Z
        datetime3: 20161022T142312Z
      invalid_sequence_1.yaml: |
        date: 1
        datetime1: â
        datetime2: b
        datetime3: c
  scenario:
    - Code: |
        from strictyaml import Map, Datetime, YAMLValidationError, load
        from datetime import datetime
        from dateutil.tz.tz import tzutc

        schema = Map({
            "date": Datetime(),
            "datetime1": Datetime(),
            "datetime2": Datetime(),
            "datetime3": Datetime(),
        })

    - Returns True: |
        load(valid_sequence, schema) == {
            "date": datetime(2016, 10, 22, 0, 0),
            "datetime1": datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc()),
            "datetime2": datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc()),
            "datetime3": datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc()),
        }

    - Returns True: |
        load(valid_sequence, schema)["date"].text == "2016-10-22"

    - Raises Exception:
        command: load(invalid_sequence_1, schema)
        exception: |
          when expecting a datetime
          found non-datetime
            in "<unicode string>", line 2, column 1:
              datetime1: "\xE2"
              ^ (line: 2)

