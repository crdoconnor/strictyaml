Bounded numbers and sequences:
  based on: strictyaml
  docs: validation/bounds
  description: |
    Int and Float accept inclusive minimum and maximum bounds. Seq and
    UniqueSeq accept inclusive minimum_size and maximum_size bounds.
    Bounds apply when loading YAML and serializing Python values.
    Unspecified bounds leave the existing behavior unchanged.
    A bounded Float rejects NaN because it cannot satisfy an ordering.
    Seq still requires a non-empty YAML sequence; a zero minimum does not
    interpret blank scalars as empty lists. Use EmptyList explicitly for that.
  given:
    setup: |
      import math
      from strictyaml import (
          Int, Float, Seq, UniqueSeq, Str, Map, EmptyList,
          load, as_document,
      )
      from strictyaml.exceptions import YAMLValidationError, YAMLSerializationError

      def rejects(error_type, function, *args):
          try:
              function(*args)
          except error_type:
              return
          raise AssertionError("Expected " + error_type.__name__)
  variations:
    Numeric inclusive boundaries:
      steps:
      - Run:
          code: |
            for kind in (Int, Float):
                schema = Map({"value": kind(minimum=-2, maximum=2)})
                for number in (-2, 0, 2):
                    assert load("value: " + str(number), schema).data["value"] == number
                    assert as_document({"value": number}, schema).data["value"] == number
                    assert as_document({"value": str(number)}, schema).data["value"] == number
                for number in (-3, 3):
                    rejects(YAMLValidationError, load, "value: " + str(number), schema)
                    rejects(YAMLSerializationError, as_document, {"value": number}, schema)
                    rejects(YAMLSerializationError, as_document, {"value": str(number)}, schema)
            assert load("value: 1_000", Map({"value": Int(minimum=1000)})).data["value"] == 1000
            assert load("value: 0.1", Map({"value": Float(maximum=0.1)})).data["value"] == 0.1
    One-sided bounds and non-finite floats:
      steps:
      - Run:
          code: |
            for validator in (Float(minimum=0), Float(maximum=1)):
                schema = Map({"value": validator})
                rejects(YAMLValidationError, load, "value: .nan", schema)
                rejects(YAMLSerializationError, as_document, {"value": float("nan")}, schema)
            assert load("value: inf", Map({"value": Float(minimum=0)})).data["value"] == float("inf")
            assert load("value: -inf", Map({"value": Float(maximum=0)})).data["value"] == float("-inf")
            rejects(YAMLValidationError, load, "value: inf", Map({"value": Float(maximum=1)}))
            assert math.isnan(load("value: nan", Map({"value": Float()})).data["value"])
            assert math.isnan(as_document({"value": float("nan")}, Map({"value": Float()})).data["value"])
    Sequence inclusive boundaries:
      steps:
      - Run:
          code: |
            for kind in (Seq, UniqueSeq):
                schema = kind(Int(), minimum_size=2, maximum_size=3)
                for values in ([1, 2], [1, 2, 3]):
                    text = "\n".join("- " + str(value) for value in values)
                    assert load(text, schema).data == values
                    assert as_document(values, schema).data == values
                for values in ([1], [1, 2, 3, 4]):
                    text = "\n".join("- " + str(value) for value in values)
                    rejects(YAMLValidationError, load, text, schema)
                    rejects(YAMLSerializationError, as_document, values, schema)
                assert load("- 1", kind(Int(), maximum_size=1)).data == [1]
                assert load("- 1", kind(Int(), minimum_size=1)).data == [1]
    Bounds retain sequence validation:
      steps:
      - Run:
          code: |
            rejects(YAMLValidationError, load, "- a\n- a", UniqueSeq(Str(), maximum_size=3))
            rejects(YAMLSerializationError, as_document, ["a", "a"], UniqueSeq(Str(), maximum_size=3))
            rejects(YAMLValidationError, load, "- invalid", Seq(Int(), minimum_size=1))
            rejects(YAMLSerializationError, as_document, ["invalid"], Seq(Int(), minimum_size=1))
            for kind in (Seq, UniqueSeq):
                rejects(YAMLValidationError, load, "", kind(Int(), minimum_size=0))
                rejects(YAMLSerializationError, as_document, [], kind(Int(), minimum_size=0))
                rejects(YAMLSerializationError, as_document, "abc", kind(Str(), maximum_size=3))
                assert load("", kind(Int(), minimum_size=0) | EmptyList()).data == []
    Reject invalid bound declarations:
      steps:
      - Run:
          code: |
            for kind in (Int, Float):
                for value in ("1", True, float("nan")):
                    rejects(ValueError, lambda: kind(minimum=value))
                    rejects(ValueError, lambda: kind(maximum=value))
                rejects(ValueError, lambda: kind(minimum=2, maximum=1))
            for kind in (Seq, UniqueSeq):
                for value in (-1, 1.5, "1", True):
                    rejects(ValueError, lambda: kind(Int(), minimum_size=value))
                    rejects(ValueError, lambda: kind(Int(), maximum_size=value))
                rejects(ValueError, lambda: kind(Int(), minimum_size=2, maximum_size=1))
    Repr includes active bounds:
      steps:
      - Run:
          code: |
            assert repr(Int()) == "Int()"
            assert repr(Float(minimum=0)) == "Float(minimum=0)"
            assert repr(Int(minimum=0, maximum=2)) == "Int(minimum=0, maximum=2)"
            assert repr(Seq(Int())) == "Seq(Int())"
            assert repr(UniqueSeq(Str(), maximum_size=2)) == "UniqueSeq(Str(), maximum_size=2)"
