---
title: Empty key validation
---


Sometimes you may wish to not specify a value or specify
that it does not exist.

Using StrictYAML you can accept this as a valid value and
have it parsed to one of three things - None, {} (empty dict),
or [] (empty list).


Example yaml_snippet:

```yaml
a:
```


```python
from strictyaml import Map, Str, Enum, EmptyNone, EmptyDict, EmptyList, NullNone, load, as_document
from ensure import Ensure

```



EmptyNone with empty value:


```python
Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Enum(["A", "B",])}))).equals({"a": None})

```




EmptyDict:


```python
Ensure(load(yaml_snippet, Map({"a": EmptyDict() | Enum(["A", "B",])}))).equals({"a": {}})

```




EmptyList:


```python
Ensure(load(yaml_snippet, Map({"a": EmptyList() | Enum(["A", "B",])}))).equals({"a": []})

```




NullNone:


```python
Ensure(load("a: null", Map({"a": NullNone() | Enum(["A", "B",])}))).equals({"a": None})

```




EmptyNone no empty value:

```yaml
a: A
```


```python
Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Enum(["A", "B",])}))).equals({"a": "A"})

```




Combine Str with EmptyNone and Str is evaluated first:


```python
Ensure(load(yaml_snippet, Map({"a": Str() | EmptyNone()}))).equals({"a": ""})

```




Combine EmptyNone with Str and Str is evaluated last:


```python
Ensure(load(yaml_snippet, Map({"a": EmptyNone() | Str()}))).equals({"a": None})

```




Non-empty value:

```yaml
a: C
```


```python
load(yaml_snippet, Map({"a": Enum(["A", "B",]) | EmptyNone()}))

```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an empty value
found arbitrary text
  in "<unicode string>", line 1, column 1:
    a: C
     ^ (line: 1)
```




Serialize empty dict:


```python
print(as_document({"a": {}}, Map({"a": EmptyDict() | Str()})).as_yaml())

```

```yaml
a:
```




Serialize empty list:


```python
print(as_document({"a": []}, Map({"a": EmptyList() | Str()})).as_yaml())

```

```yaml
a:
```




Serialize None:


```python
print(as_document({"a": None}, Map({"a": EmptyNone() | Str()})).as_yaml())

```

```yaml
a:
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/empty.story">empty.story
    storytests.