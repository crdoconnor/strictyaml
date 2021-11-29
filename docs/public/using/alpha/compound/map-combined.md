---
title: Mappings combining defined and undefined keys (MapCombined)
---

!!! warning "Experimental"

    This feature is in alpha. The API may change on a minor version increment.


When you wish to support arbitrary optional keys in
some mappings (i.e. to specify some required keys in
the schema, but allow any additional ones on top of
that), you use a MapCombined.

See https://github.com/crdoconnor/strictyaml/issues/148#issuecomment-861007657




```python
from strictyaml import Any, Int, MapCombined, Optional, Str, load
from ensure import Ensure

schema = MapCombined(
  {
    "required": Str(),
    Optional("foo"): Int(),
  },
  Str(),
  Any(),
)

```



Optional is present:

```yaml
required: Hello World
foo: 42
bar: 42

```


```python
Ensure(load(yaml_snippet, schema).data).equals(
    {
        "required": "Hello World",
        "foo": 42,
        "bar": "42",
    }
)

```




Optional is absent:

```yaml
required: Hello World
bar: 42

```


```python
Ensure(load(yaml_snippet, schema).data).equals(
    {
        "required": "Hello World",
        "bar": "42",
    }
)

```




Multiple undefined:

```yaml
required: Hello World
bar: 42
baz: forty two

```


```python
Ensure(load(yaml_snippet, schema).data).equals(
    {
        "required": "Hello World",
        "bar": "42",
        "baz": "forty two",
    }
)

```




Required is absent:

```yaml
bar: 42

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
required key(s) 'required' not found
  in "<unicode string>", line 1, column 1:
    bar: '42'
     ^ (line: 1)
```




Undefined of invalid type:

```yaml
required: Hello World
bar: forty two

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found arbitrary text
  in "<unicode string>", line 2, column 1:
    bar: forty two
    ^ (line: 2)
```




Invalid key type:

```yaml
1: Hello World
not_an_integer: 42

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found arbitrary text
  in "<unicode string>", line 2, column 1:
    not_an_integer: '42'
    ^ (line: 2)
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/map-combined.story">map-combined.story
    storytests.