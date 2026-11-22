Long scalar lines retain their line numbers:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import Map, ScalarValidator, Str, YAMLValidationError, load

      class Lower(ScalarValidator):
          def validate_scalar(self, chunk):
              return chunk.contents.lower()

      long_value = "word " * 30 + "caf\u00e9"
      yaml_snippet = "Title: " + long_value + "\nSummary: " + long_value + "\nUnknown: value\n"
  variations:
    Validation errors use the original long lines:
      steps:
      - Run: |
          try:
              load(yaml_snippet, Map({"title": Str(), "summary": Str()}, Lower()))
          except YAMLValidationError as error:
              assert error.context_mark.line == 2, str(error)
              assert error.problem_mark.line == 2, str(error)
              assert "Unknown: value" in str(error)
          else:
              raise AssertionError("Expected an unexpected-key error")
    Scalar line access does not wrap preceding text:
      steps:
      - Run: |
          parsed = load(yaml_snippet)
          assert parsed["Summary"].start_line == 2
          assert parsed["Summary"].end_line == 2
          assert parsed["Unknown"].start_line == 3
          assert parsed["Unknown"].end_line == 3
          assert parsed["Summary"].lines_before(1) == "Title: " + long_value
          assert parsed["Summary"].lines() == "Summary: " + long_value
          assert parsed["Summary"].lines_after(1) == "Unknown: value"
