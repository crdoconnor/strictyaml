Mapping with defined keys and a custom key validator (Map):
  docs: compound/mapping-with-slug-keys
  based on: strictyaml
  experimental: yes
  description: |
    A typical mapping except that the key values are determined
    by the value provided by the validator.
  given:
    setup: |
      from collections import OrderedDict
      from strictyaml import Map, Optional, Str, Seq, load, ScalarValidator
      from ensure import Ensure
      
      # This example uses slugify from the "python-slugify" package
      from slugify import slugify

      class Slug(ScalarValidator):
          def validate_scalar(self, chunk):
              return slugify(unicode(chunk.contents))

      schema = Map({
          "name": Str(),
          Optional("country-code"): Str(),
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
  based on: Mapping with defined keys and a custom key validator (Map)
  steps:
  - Run: |
      yaml = load(yaml_snippet, schema)
      yaml.revalidate(schema)


Slug key validation getitem setitem and delitem:
  description: |
    You can set properties on slug key validated by
    using a key that turns into the same slug as the text
    key. E.g.
    
    DIAL CODE -> dial-code
    dial code -> dial-code
    
    Therefore treated as the same key.
  based on: Mapping with defined keys and a custom key validator (Map)
  variations:
    Getting:
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            Ensure(yaml['dial code']).equals("+44")

    Setting:
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            yaml.revalidate(schema)
            yaml['dial-code'] = "+48"
            print(yaml.as_yaml())
          will output: |-
            Name: United Kingdom
            country-code: GB
            DIAL CODE: +48
            official languages:
            - English
            - Welsh

    Deleting:
      steps:
      - Run:
          code: |
            yaml = load(yaml_snippet, schema)
            del yaml['dial code']
            print(yaml.as_yaml())
          will output: |-
            Name: United Kingdom
            country-code: GB
            official languages:
            - English
            - Welsh
