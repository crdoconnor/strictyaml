---
title: Parsing YAML without a schema
type: using
---


When using strictyaml you do not have to specify a schema. If
you do this, the validator "Any" is used which will accept any
mapping and any list and any scalar values (which will always be
interpreted as a string, unlike regular YAML).

This is the recommended approach when rapidly prototyping and the
desired schema is fluid.

When your prototype code is parsing YAML that has a more fixed
structure, we recommend that you 'lock it down' with a schema.

The Any validator can be used inside fixed structures as well.


Example yaml_snippet:

```yaml
a:
  x: 9
  y: 8
b: 2
c: 3

```


```python
from strictyaml import Str, Any, MapPattern, load
from ensure import Ensure

```



Parse without validator:


```python
Ensure(load(yaml_snippet)).equals({"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"})

```




Parse with any validator - equivalent:


```python
Ensure(load(yaml_snippet, Any())).equals({"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"})

```




Fix higher levels of schema:


```python
Ensure(load(yaml_snippet, MapPattern(Str(), Any()))).equals({"a": {"x": "9", "y": "8"}, "b": "2", "c": "3"})

```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/non-schema-validation.story">non-schema-validation.story</a>.
{{< /note >}}