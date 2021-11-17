---
title: Using a YAML object of a parsed mapping
type: using
---


When a YAML document with mappings is parsed, it is not parsed
as a dict but as a YAML object which behaves very similarly to
a dict, but with some extra capabilities.

You can use .items(), .keys(), .values(), look up items with
square bracket notation, .get(key, with_default_if_nonexistent)
and use "x in y" notation to determine key membership.

To retrieve the equivalent dict (containing just other dicts, lists
and strings/ints/etc.) use .data.


Example yaml_snippet:

```yaml
a: 1
b: 2
c: 3

```


```python
from strictyaml import Map, Int, load
from ensure import Ensure

schema = Map({"a": Int(), "b": Int(), "c": Int()})

```



.is_mapping():


```python
Ensure(load(yaml_snippet, schema).is_mapping()).is_true()

```




Equivalence with equivalent plain dict:


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1, "b": 2, "c": 3})

```




.items():


```python
Ensure(load(yaml_snippet, schema).items()).equals([("a", 1), ("b", 2), ("c", 3)])

```




Use in to detect presence of a key:


```python
Ensure("a" in load(yaml_snippet, schema)).is_true()

```




.values():


```python
Ensure(load(yaml_snippet, schema).values()).equals([1, 2, 3])

```




.keys():


```python
Ensure(load(yaml_snippet, schema).keys()).equals(["a", "b", "c"])

```




Key lookup:


```python
yaml = load(yaml_snippet, schema)
Ensure(yaml[yaml.keys()[0]]).equals(1)

```




Dict lookup:


```python
Ensure(load(yaml_snippet, schema)["a"]).equals(1)

```




.get():


```python
Ensure(load(yaml_snippet, schema).get("a")).equals(1)

```




.get() nonexistent:


```python
Ensure(load(yaml_snippet, schema).get("nonexistent")).equals(None)

```




len():


```python
Ensure(len(load(yaml_snippet, schema))).equals(3)

```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/mapping-representation.story">mapping-representation.story</a>.
{{< /note >}}