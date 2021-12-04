---
title: Why not use JSON Schema for validation?
---

JSON schema can also be used to validate YAML. This presumes that
you might want to use jsonschema and yaml together.

StrictYAML was inspired by the frustration of trying to use
pyyaml with [pykwalify](https://pykwalify.readthedocs.io/),
in fact.

## Loss of line numbers

Because parsing first with pyyaml and then passing the result
to pykwalify loses line numbers, validation errors lose the
line number where the validation error occurred.

This makes tracking down the location of errors tricky. If
a schema is a little repetitive it can make tracking down
the exact location of the error hellish.

# Simpler errors in StrictYAML

StrictYAML has an emphasis on the friendliness of schema
validation errors. Ideally every schema validation error
should be extremely obvious and show only the information
necessary.

# StrictYAML schemas are more flexible

Because schemas are written in python and strictyaml allows
revalidation, strictyaml schemas are much more flexible:

Example:

```python
from strictyaml import load, Seq, Enum
import pycountry    # updated list of country codes


load(
    strictyaml_string,
    Map(
        {
            "countries": Seq(Enum([country.alpha_2 for country in pycountry.countries]))
        }
    )
)
```
