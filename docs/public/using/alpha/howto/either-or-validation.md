---
title: Either/or schema validation of different, equally valid different kinds of YAML
---


StrictYAML can be directed to parse two different elements or
blocks of YAML.

If the first thing does not parse correctly, it attempts to
parse the second. If the second does not parse correctly,
it raises an exception.




```python
from strictyaml import Map, Seq, Bool, Int, Str, YAMLValidationError, load
from ensure import Ensure

schema = Str() | Map({"a": Bool() | Int()})

```



Boolean first choice true:

```yaml
a: yes
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": True})

```




Boolean first choice false:

```yaml
a: no
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": False})

```




Int second choice:

```yaml
a: 5
```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 5})

```




Invalid not bool or int:

```yaml
a: A
```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found arbitrary text
  in "<unicode string>", line 1, column 1:
    a: A
     ^ (line: 1)
```




Invalid combinations of more than one map:

```yaml
a: x
```


```python
load(yaml_snippet, Map({"a": Str()}) | Map({"b": Str()}))

```


```python
strictyaml.exceptions.InvalidValidatorError:
You tried to Or ('|') together 2 Map validators. Try using revalidation instead.
```




Invalid combinations of more than one seq:

```yaml
- 1
- 2

```


```python
load(yaml_snippet, Seq(Int()) | Seq(Str()))

```


```python
strictyaml.exceptions.InvalidValidatorError:
You tried to Or ('|') together 2 Seq validators. Try using revalidation instead.
```




Change item after validated:

```yaml
a: yes
```


```python
yaml = load(yaml_snippet, schema)
yaml['a'] = 5
assert yaml['a'] == 5

```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/or.story">or.story
    storytests.