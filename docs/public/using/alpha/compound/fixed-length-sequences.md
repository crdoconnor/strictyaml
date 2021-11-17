---
title: Fixed length sequences (FixedSeq)
type: using
---


Sequences of fixed length can be validated with a series
of different (or the same) types.




```python
from strictyaml import FixedSeq, Str, Map, Int, Float, YAMLValidationError, load
from ensure import Ensure

schema = FixedSeq([Int(), Map({"x": Str()}), Float()])

```



Equivalent list:

```yaml
- 1
- x: 5
- 2.5

```


```python
Ensure(load(yaml_snippet, schema)).equals([1, {"x": "5"}, 2.5, ])

```




Invalid list 1:

```yaml
a: 1
b: 2
c: 3

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a sequence of 3 elements
  in "<unicode string>", line 1, column 1:
    a: '1'
     ^ (line: 1)
found a mapping
  in "<unicode string>", line 3, column 1:
    c: '3'
    ^ (line: 3)
```




Invalid list 2:

```yaml
- 2
- a
- a:
  - 1
  - 2

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a mapping
found arbitrary text
  in "<unicode string>", line 2, column 1:
    - a
    ^ (line: 2)
```




Invalid list 3:

```yaml
- 1
- a

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a sequence of 3 elements
  in "<unicode string>", line 1, column 1:
    - '1'
     ^ (line: 1)
found a sequence of 2 elements
  in "<unicode string>", line 2, column 1:
    - a
    ^ (line: 2)
```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/fixed-sequence.story">fixed-sequence.story</a>.
{{< /note >}}