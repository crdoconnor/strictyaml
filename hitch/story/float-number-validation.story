Floating point validation requires digits:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import (
          Decimal, EmptyNone, Float, Map, Optional, Str,
          YAMLValidationError, as_document, load,
      )
  variations:
    Optional empty default after Float:
      steps:
      - Run: |
          for value_schema in (Float() | EmptyNone(), EmptyNone() | Float()):
              schema = Map({
                  "mode": Str(),
                  Optional("duration", default=None, drop_if_none=False): value_schema,
              })
              assert load("mode: default", schema).data == {
                  "mode": "default", "duration": None,
              }
    Empty value can fall back to Str:
      steps:
      - Run: |
          assert load("value:", Map({"value": Float() | Str()})).data == {"value": ""}
    Invalid floats raise validation errors:
      steps:
      - Run: |
          for value in ("", ".", "+", "-", "_", "._", "e10", "1e_", "1e+_"):
              try:
                  load("value: '" + value + "'", Map({"value": Float()}))
              except YAMLValidationError:
                  pass
              else:
                  raise AssertionError("Accepted invalid float: " + repr(value))
    Invalid decimals raise validation errors:
      steps:
      - Run: |
          for value in ("", ".", "+", "-", "_", "._", "e10", "1e_", "1e+_"):
              try:
                  load("value: '" + value + "'", Map({"value": Decimal()}))
              except YAMLValidationError:
                  pass
              else:
                  raise AssertionError("Accepted invalid decimal: " + repr(value))
    Valid numeric spellings:
      steps:
      - Run: |
          for value in ("0", "4.", ".5", "-.5e+2", "1e-2", "10_0.2_5", "1e1_0"):
              expected = float(value.replace("_", ""))
              assert load("value: " + value, Map({"value": Float()})).data == {"value": expected}
              assert as_document({"value": value}, Map({"value": Float()})).data == {"value": expected}
