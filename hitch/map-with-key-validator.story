Map with slug key validator:
  docs: compound/mapping-with-slug-keys
  based on: strictyaml
  description: |
    A typical mapping except that the key values are determined
    by the value provided by the validator.
  given:
    setup: |
      from collections import OrderedDict
      from strictyaml import Map, Str, Seq, load, ScalarValidator
      from ensure import Ensure
      
      # This example uses slugify from the "python-slugify" package
      from slugify import slugify

      class Slug(ScalarValidator):
          def validate_scalar(self, chunk):
              return slugify(unicode(chunk.contents))

      schema = Map({
          "name": Str(),
          "country-code": Str(),
          "dial-code": Str(),
          "official-languages": Seq(Str())
      }, key_validator=Slug())
    yaml_snippet: |
      Name: United Kingdom
      country-code: GB
      DIAL CODE: +44
      official languages:
      - English
      - Welsh
  steps:
  - Run: |
      Ensure(load(yaml_snippet, schema).data).equals(
          {
              "name": "United Kingdom",
              "country-code": "GB",
              "dial-code": "+44",
              "official-languages": ["English", "Welsh"],
          }
      )


Slug key validator revalidation bug:
  based on: Map with slug key validator
  steps:
  - Run: |
      yaml = load(yaml_snippet, schema)
      yaml.revalidate(schema)


Roundtripping maps with slug key validator:
  description: |
    You can set properties on slug key validated by
    using a key that turns into the same slug as the text
    key. E.g.
    
    DIAL CODE -> dial-code
    dial code -> dial-code
    
    Therefore treated as the same key.
  based on: Map with slug key validator
  steps:
  - Run:
      code: |
        yaml = load(yaml_snippet, schema)
        yaml['dial code'] = '+48'
        print(yaml.as_yaml())
      will output: |-
        Name: United Kingdom
        country-code: GB
        DIAL CODE: +48
        official languages:
        - English
        - Welsh
