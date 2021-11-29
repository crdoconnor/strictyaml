---
title: Validating optional keys in mappings (Map)
---


Not every key in a YAML mapping will be required. If
you use the "Optional('key')" validator with YAML,
you can signal that a key/value pair is not required.




```python
from strictyaml import Map, Int, Str, Bool, Optional, load
from ensure import Ensure

schema = Map({"a": Int(), Optional("b"): Bool(), })

```



Valid example 1:

```yaml
a: 1
b: yes

```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": True})

```




Valid example 2:

```yaml
a: 1
b: no

```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": False})

```




Valid example missing key:

```yaml
a: 1
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1})

```




Invalid 1:

```yaml
a: 1
b: 2

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a boolean value (one of "yes", "true", "on", "1", "y", "no", "false", "off", "0", "n")
found an arbitrary integer
  in "<unicode string>", line 2, column 1:
    b: '2'
    ^ (line: 2)
```




Invalid 2:

```yaml
a: 1
b: yes
c: 3

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
unexpected key not in schema 'c'
  in "<unicode string>", line 3, column 1:
    c: '3'
    ^ (line: 3)
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/optional.story">optional.story
    storytests.