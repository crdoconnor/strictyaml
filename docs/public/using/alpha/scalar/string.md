---
title: Parsing strings (Str)
type: using
---


StrictYAML parses to a YAML object, not
the value directly to give you more flexibility
and control over what you can do with the YAML.

This is what that can object can do - in most
cases if parsed as a string, it will behave in
the same way.


Example yaml_snippet:

```yaml
a: 1
b: yes
c: â string
d: |
  multiline string

```


```python
from strictyaml import Str, Map, load
from ensure import Ensure

schema = Map({"a": Str(), "b": Str(), "c": Str(), "d": Str()})

parsed = load(yaml_snippet, schema)

```



Parses correctly:


```python
Ensure(parsed).equals(
    {"a": "1", "b": "yes", "c": u"â string", "d": "multiline string\n"}
)

```




Dict lookup cast to string:


```python
Ensure(str(parsed["a"])).equals("1")
```




Dict lookup cast to int:


```python
Ensure(int(parsed["a"])).equals(1)

```




Dict lookup cast to bool impossible:


```python
bool(parsed["a"])
```


```python
:
Cannot cast 'YAML(1)' to bool.
Use bool(yamlobj.data) or bool(yamlobj.text) instead.
```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/scalar-string.story">scalar-string.story</a>.
{{< /note >}}