Optional keys must be strings:
  based on: strictyaml
  given:
    setup: |
      from strictyaml import Int, Map, Optional, Str, load
      from strictyaml.exceptions import InvalidValidatorError
  variations:
    Reject validators as keys:
      steps:
      - Run:
          code: Optional(Str())
          raises:
            type: strictyaml.exceptions.InvalidValidatorError
            message: Optional() expects a string key, not a validator.
    Reject other non-string keys:
      steps:
      - Run: |
          for key in (None, True, 1, 1.5, [], {}, ("name",)):
              try:
                  Optional(key)
              except InvalidValidatorError as error:
                  assert str(error) == "Optional() expects a string key."
              else:
                  raise AssertionError("Accepted invalid key: " + repr(key))
    Accept string keys and preserve defaults:
      steps:
      - Run: |
          schema = Map({"name": Str(), Optional("age", default=10): Int()})
          assert load("name: Alice", schema).data == {"name": "Alice", "age": 10}
          assert Optional(u"caf\u00e9").key == u"caf\u00e9"
          assert Optional("").key == ""
