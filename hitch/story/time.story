Times of day (Time):
  based on: strictyaml
  docs: scalar/time
  description: |
    Time validates a time of day without inferring a calendar date.
    Use HH:MM or HH:MM:SS, optionally with up to six fractional second
    digits and an ISO offset (Z or +HH:MM / -HH:MM). Offset seconds and
    fractional seconds are also supported for datetime.time round trips.
    Hours must be 00 through 23; leap seconds and 24:00 are rejected.
    Use .data to obtain datetime.time. A time without an offset remains
    naive; this validator does not select a timezone or schedule an event.
  given:
    setup: |
      from datetime import datetime, time, timezone, timedelta
      from strictyaml import Time, Datetime, Map, load, as_document
      from strictyaml.exceptions import YAMLValidationError, YAMLSerializationError

      def rejects(error_type, function, *args):
          try:
              function(*args)
          except error_type:
              return
          raise AssertionError("Expected " + error_type.__name__)
  variations:
    Read times without a date:
      steps:
      - Run:
          code: |
            schema = Map({"at": Time()})
            for text, expected in [
                ("00:00", time(0)),
                ("09:30", time(9, 30)),
                ("23:59:59.123456", time(23, 59, 59, 123456)),
                ("09:30Z", time(9, 30, tzinfo=timezone.utc)),
                ("09:30+05:30", time(9, 30, tzinfo=timezone(timedelta(hours=5, minutes=30)))),
                ("09:30-04:00", time(9, 30, tzinfo=timezone(-timedelta(hours=4)))),
            ]:
                result = load("at: " + text, schema)["at"]
                assert result.data == expected
                assert isinstance(result.data, time)
                assert result.text == text
    Round trip Python times and strings:
      steps:
      - Run:
          code: |
            schema = Map({"at": Time()})
            for value in (
                time(9, 30), time(23, 59, 59, 123456),
                time(9, tzinfo=timezone.utc),
                time(9, tzinfo=timezone(timedelta(hours=5, minutes=30, seconds=4))),
                time(9, tzinfo=timezone(timedelta(seconds=-30, microseconds=-123456))),
            ):
                serialized = as_document({"at": value}, schema).as_yaml()
                assert load(serialized, schema).data["at"] == value
            assert as_document({"at": "09:30"}, schema).as_yaml() == "at: 09:30\n"
            assert repr(Time()) == "Time()"
    Reject invalid times and dates:
      steps:
      - Run:
          code: |
            schema = Map({"at": Time()})
            for text in (
                "", "9:30", "09", "0930", "24:00", "12:60", "12:30:60",
                "12:30:00.1234567", "2026-01-02", "2026-01-02T09:30",
                "09:30+24:00", "09:30+01:99", "09:30+01:00:99",
                "noon", "09:30 extra", "１２:３０",
            ):
                rejects(YAMLValidationError, load, "at: " + text, schema)
                rejects(YAMLSerializationError, as_document, {"at": text}, schema)
            for value in (None, 930, datetime(2026, 1, 2, 9, 30), []):
                rejects(YAMLSerializationError, as_document, {"at": value}, schema)
