Revalidate an already validated document:
  docs: howto/revalidation
  based on: strictyaml
  description: |
    When parsing a YAML document you may wish to do more than one validation
    pass over a document.

    This is needed when:
    
    * It simplifies your code to apply validation in stages.
    * You want to validate recursively.
    * One part of the document validation depends upon another (this is the example given below).
  given:
    setup: |
      from strictyaml import Str, Int, Map, Seq, Any, load
      from ensure import Ensure

      overall_schema = Map({"capitals": Any(), "countries": Seq(Str())})
      parsed = load(yaml_snippet, overall_schema)

    yaml_snippet: |
      capitals:
        UK: 1
        Germany: 2
      countries:
        - Germany
        - UK
  variations:
    Reparse mapping:
      steps:
      - Run:
          code: |
            Ensure(parsed.data['capitals']['UK']).equals("1")
            parsed['capitals'].revalidate(Map({capital: Int() for capital in parsed.data['countries']}))
            Ensure(parsed.data['capitals']['UK']).equals(1)

    Reparse scalar:
      steps:
      - Run:
          code: |
            Ensure(parsed.data['capitals']['UK']).equals("1")
            parsed['capitals']['UK'].revalidate(Int())
            
            Ensure(parsed.data['capitals']['UK']).equals(1)
            Ensure(parsed['capitals']['UK'].data).is_an(int)

    Parse error:
      given:
        yaml_snippet: |
          capitals:
            UK: 1
            Germany: 2
            France: 3
          countries:
            - Germany
            - UK
      steps:
      - Run:
          code: |
            parsed['capitals'].revalidate(Map({capital: Int() for capital in parsed.data['countries']}))
          raises:
            type: strictyaml.exceptions.YAMLValidationError
            message: |-
              while parsing a mapping
              unexpected key not in schema 'France'
                in "<unicode string>", line 4, column 1:
                    France: '3'
                  ^ (line: 4)

    Reparse after failed mapping validation:
      steps:
      - Run:
          code: |
            from strictyaml import as_document, YAMLValidationError

            parsed = as_document({"a": 1, "b": "x"})
            try:
                parsed.revalidate(Map({"a": Int(), "b": Int()}))
            except YAMLValidationError:
                pass
            else:
                raise AssertionError("Expected integer validation to fail")

            schema = Map({"a": Int(), "b": Str()})
            parsed.revalidate(schema)
            parsed.revalidate(schema)
            Ensure(parsed.data).equals({"a": 1, "b": "x"})
            Ensure(list(parsed.data)).equals(["a", "b"])

    Reparse after failed nested mapping validation:
      steps:
      - Run:
          code: |
            from strictyaml import YAMLValidationError

            parsed = load("outer:\n  a: 1\n  b: x\n")
            try:
                parsed["outer"].revalidate(Map({"a": Int(), "b": Int()}))
            except YAMLValidationError:
                pass
            else:
                raise AssertionError("Expected integer validation to fail")

            parsed["outer"].revalidate(Map({"a": Int(), "b": Str()}))
            Ensure(parsed.data).equals({"outer": {"a": 1, "b": "x"}})
            Ensure(list(parsed.data["outer"])).equals(["a", "b"])

    Reparse normalized keys after failed mapping validation:
      steps:
      - Run:
          code: |
            from strictyaml import ScalarValidator, YAMLValidationError
            from slugify import slugify

            class Slug(ScalarValidator):
                def validate_scalar(self, chunk):
                    return slugify(chunk.contents)

            parsed = load(
                "First Key: 1\nSecond Key: x\n",
                Map({"first-key": Str(), "second-key": Str()}, key_validator=Slug()),
            )
            try:
                parsed.revalidate(
                    Map({"first-key": Int(), "second-key": Int()}, key_validator=Slug())
                )
            except YAMLValidationError:
                pass
            else:
                raise AssertionError("Expected integer validation to fail")

            parsed.revalidate(
                Map({"first-key": Int(), "second-key": Str()}, key_validator=Slug())
            )
            Ensure(parsed.data).equals({"first-key": 1, "second-key": "x"})
            Ensure(list(parsed.data)).equals(["first-key", "second-key"])
