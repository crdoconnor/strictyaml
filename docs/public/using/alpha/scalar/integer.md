---
title: Integers (Int)
---


StrictYAML parses to a YAML object, not
the value directly to give you more flexibility
and control over what you can do with the YAML.

This is what that can object can do - in many
cases if parsed as a integer, it will behave in
the same way.


Example yaml_snippet:

```yaml
a: 1
b: 5

```


```python
from strictyaml import Map, Int, load
from ensure import Ensure

schema = Map({"a": Int(), "b": Int()})

parsed = load(yaml_snippet, schema)

```



Parsed correctly:


```python
Ensure(parsed).equals({"a": 1, "b": 5})

```




Has underscores:

```yaml
a: 10_000_000
b: 10_0_0

```


```python
Ensure(load(yaml_snippet, schema).data).equals({"a": 10000000, "b": 1000})

```




Cast with str:


```python
Ensure(str(parsed["a"])).equals("1")
```




Cast with float:


```python
Ensure(float(parsed["a"])).equals(1.0)
```




Greater than:


```python
Ensure(parsed["a"] > 0).equals(True)
```




Less than:


```python
Ensure(parsed["a"] < 2).equals(True)
```




To get actual int, use .data:


```python
Ensure(type(load(yaml_snippet, schema)["a"].data) is int).equals(True)
```




Cannot cast to bool:


```python
bool(load(yaml_snippet, schema)['a'])
```


```python
:
Cannot cast 'YAML(1)' to bool.
Use bool(yamlobj.data) or bool(yamlobj.text) instead.
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/scalar-integer.story">scalar-integer.story
    storytests.