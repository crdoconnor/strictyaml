---
title: Mapping with defined keys and a custom key validator (Map)
---

!!! warning "Experimental"

    This feature is in alpha. The API may change on a minor version increment.


A typical mapping except that the key values are determined
by the value provided by the validator.


Example yaml_snippet:

```yaml
Name: United Kingdom
country-code: GB
DIAL CODE: +44
official languages:
- English
- Welsh

```


```python
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

```



```python
Ensure(load(yaml_snippet, schema).data).equals(
    {
        "name": "United Kingdom",
        "country-code": "GB",
        "dial-code": "+44",
        "official-languages": ["English", "Welsh"],
    }
)

```






!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/map-with-key-validator.story">map-with-key-validator.story
    storytests.