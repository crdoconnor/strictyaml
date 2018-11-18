Datetimes (Datetime):
  docs: scalar/datetime
  based on: strictyaml
  description: |
    Datetime validator parses using the python-dateutil library and
    returns a python datetime object.
  given:
    setup: |
      from strictyaml import Map, Datetime, YAMLValidationError, load, as_document
      from collections import OrderedDict
      from dateutil.tz.tz import tzutc
      from datetime import datetime
      from ensure import Ensure

      schema = Map({
          "date": Datetime(),
          "datetime1": Datetime(),
          "datetime2": Datetime(),
          "datetime3": Datetime(),
      })

      equivalent_data = OrderedDict([
          ("date", datetime(2016, 10, 22, 0, 0)),
          ("datetime1", datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc())),
          ("datetime2", datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc())),
          ("datetime3", datetime(2016, 10, 22, 14, 23, 12, tzinfo=tzutc())),
      ])
    yaml_snippet: |
      date: 2016-10-22
      datetime1: 2016-10-22T14:23:12+00:00
      datetime2: 2016-10-22T14:23:12Z
      datetime3: 20161022T142312Z
  variations:
    Each of the four datetimes are valid and parsed:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)).equals(equivalent_data)

    .text still returns the original text:
      steps:
      - Run:
          code: |
            Ensure(load(yaml_snippet, schema)["date"].text).equals("2016-10-22")

    Non datetimes raise an exception:
      given:
        yaml_snippet: |
          date: 1
          datetime1: â
          datetime2: b
          datetime3: c
      steps:
      - Run:
          code: load(yaml_snippet, schema)
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              when expecting a datetime
              found arbitrary text
                in "<unicode string>", line 2, column 1:
                  datetime1: "\xE2"
                  ^ (line: 2)

    Datetime objects serialize directly to ISO-8601 format YAML strings:
      steps:
      - Run:
          code: |
            print(as_document(equivalent_data, schema).as_yaml())
          will output: |-
            date: 2016-10-22T00:00:00
            datetime1: 2016-10-22T14:23:12+00:00
            datetime2: 2016-10-22T14:23:12+00:00
            datetime3: 2016-10-22T14:23:12+00:00

    Valid datetime strings serialize to YAML:
      steps:
      - Run:
          code: |
            print(as_document({"a": "2016-10-22"}, Map({"a": Datetime()})).as_yaml())
          will output: 'a: 2016-10-22'

    Serializing invalid datetime string raises exception:
      steps:
      - Run:
          code: |
            as_document({"a": "x"}, Map({"a": Datetime()}))
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: expected a datetime, got 'x'

    Serializing non-string and non-datetime object raises exception:
      steps:
      - Run:
          code: |
            as_document({"a": 55}, Map({"a": Datetime()}))
          raises:
            type: strictyaml.exceptions.YAMLSerializationError
            message: expected a datetime, got '55' of type 'int'
