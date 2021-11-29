---
title: Email and URL validators
---


StrictYAML can validate emails (using a simplified regex) and
URLs.




```python
from strictyaml import Email, Url, Map, load
from ensure import Ensure

schema = Map({"a": Email(), "b": Url()})

```



Parsed:

```yaml
a: billg@microsoft.com
b: http://www.twitter.com/@realDonaldTrump

```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": "billg@microsoft.com", "b": "http://www.twitter.com/@realDonaldTrump"})

```




Exception:

```yaml
a: notanemail
b: notaurl

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an email address
found non-matching string
  in "<unicode string>", line 1, column 1:
    a: notanemail
     ^ (line: 1)
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/email-url.story">email-url.story
    storytests.