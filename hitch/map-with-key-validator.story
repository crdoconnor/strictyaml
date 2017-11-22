Map with slug key validator:
  docs: compound/mapping-with-slug-keys
  based on: strictyaml
  description: |
    A typical mapping except that the key values are determined
    by the value provided by the validator.
  given:
    setup: |
      from collections import OrderedDict
      from strictyaml import Map, Str, load, ScalarValidator
      from ensure import Ensure
      
      # This example uses slugify from the "python-slugify" package
      from slugify import slugify

      class Slug(ScalarValidator):
          def validate_scalar(self, chunk):
              return slugify(unicode(chunk.contents))
          
          def __repr__(self):
              return u"Slug()"

      schema = Map({"name": Str(), "country-code": Str(), "dial-code": Str()}, key_validator=Slug())
    yaml_snippet: |
      Name: United Kingdom
      country-code: GB
      DIAL CODE: +44
  steps:
  - Run:
      code: |
        Ensure(load(yaml_snippet, schema).data).equals(
            {"name": "United Kingdom", "country-code": "GB", "dial-code": "+44"}
        )
