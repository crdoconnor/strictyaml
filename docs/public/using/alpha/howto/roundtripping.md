---
title: Reading in YAML, editing it and writing it back out
---


Loaded YAML can be modified and dumped out again with
comments preserved using .as_yaml().

Note that due to some bugs in the library (ruamel.yaml)
underlying StrictYAML, while the data parsed should
be precisely the same, the exact syntax (newlines, comment
locations, etc.) may not be identical.


Example yaml_snippet:

```yaml
# Some comment

a: â # value comment

# Another comment
b:
  x: 4
  y: 5
c:
- a: 1
- b: 2

```


```python
from strictyaml import Map, MapPattern, EmptyDict, Str, Seq, Int, load
from ensure import Ensure

schema = Map({
    "a": Str(),
    "b": Map({"x": Int(), "y": Int()}),
    "c": EmptyDict() | Seq(MapPattern(Str(), Str())),
})

```



Commented:


```python
Ensure(load(yaml_snippet, schema).as_yaml()).equals(yaml_snippet)

```




Modified with invalid variable:


```python
to_modify = load(yaml_snippet, schema)
to_modify['b']['x'] = 2
to_modify['c'][0]['a'] = '3'
to_modify['b']['x'] = 'not an integer'

```


```python
strictyaml.exceptions.YAMLSerializationError:
'not an integer' not an integer.
```




Modified with float:


```python
to_modify = load(yaml_snippet, schema)
to_modify['c'][0]['a'] = "1.0001"
print(to_modify.as_yaml())

```

```yaml
# Some comment

a: â # value comment

# Another comment
b:
  x: 4
  y: 5
c:
- a: 1.0001
- b: 2
```




Modify multi line string:

```yaml
a: some
b: |
  text

```


```python
schema = Map({"a": Str(), "b": Str()})
to_modify = load(yaml_snippet, schema)
to_modify['a'] = 'changed'
print(to_modify.as_yaml())

```

```yaml
a: changed
b: |
  text
```




Modified with one variable:


```python
to_modify = load(yaml_snippet, schema)
to_modify['b']['x'] = 2
to_modify['c'][0]['a'] = '3'
print(to_modify.as_yaml())

```

```yaml
# Some comment

a: â # value comment

# Another comment
b:
  x: 2
  y: 5
c:
- a: 3
- b: 2
```




Text across lines:


```python
to_modify = load(yaml_snippet, schema)

to_modify['c'][0]['a'] = "text\nacross\nlines"
print(to_modify.as_yaml())

```

```yaml
# Some comment

a: â # value comment

# Another comment
b:
  x: 4
  y: 5
c:
- a: |-
    text
    across
    lines
- b: 2
```




With empty dict:


```python
to_modify = load(yaml_snippet, schema)

to_modify['c'] = {}
print(to_modify.as_yaml())

```

```yaml
# Some comment

a: â # value comment

# Another comment
b:
  x: 4
  y: 5
c:
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/roundtrip.story">roundtrip.story
    storytests.