---
title: Enumerated scalars (Enum)
---


StrictYAML allows you to ensure that a scalar
value can only be one of a set number of items.

It will throw an exception if any strings not
in the list are found.




```python
from strictyaml import Map, Enum, MapPattern, YAMLValidationError, load
from collections import OrderedDict
from ensure import Ensure

schema = Map({"a": Enum(["A", "B", "C"])})

```



Valid because it contains 'A':

```yaml
a: A
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": "A"})

```




Get .data from enum:

```yaml
a: A
```


```python
assert isinstance(load(yaml_snippet, schema)['a'].data, str)

```




Valid because it contains 'B':

```yaml
a: B
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": "B"})

```




Valid because it contains 'C':

```yaml
a: C
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": "C"})

```




Invalid because D is not in enum:

```yaml
a: D
```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting one of: A, B, C
found arbitrary text
  in "<unicode string>", line 1, column 1:
    a: D
     ^ (line: 1)
```




Invalid because blank string is not in enum:

```yaml
a:
```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting one of: A, B, C
found a blank string
  in "<unicode string>", line 1, column 1:
    a: ''
     ^ (line: 1)
```




Successful serialization:

```yaml
a: A
```


```python
yaml = load(yaml_snippet, schema)
yaml['a'] = "B"
print(yaml.as_yaml())

```

```yaml
a: B
```




Invalid serialization:

```yaml
a: A
```


```python
yaml = load(yaml_snippet, schema)
yaml['a'] = "D"
print(yaml.as_yaml())

```


```python
strictyaml.exceptions.YAMLSerializationError:
Got 'D' when  expecting one of: A, B, C
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/enum.story">enum.story
    storytests.