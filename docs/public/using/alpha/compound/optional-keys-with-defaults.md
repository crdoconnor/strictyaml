---
title: Optional keys with defaults (Map/Optional)
---

!!! warning "Experimental"

    This feature is in alpha. The API may change on a minor version increment.




Example yaml_snippet:

```yaml
a: 1

```


```python
from strictyaml import Map, Int, Str, Bool, EmptyNone, Optional, load, as_document
from collections import OrderedDict
from ensure import Ensure

schema = Map({"a": Int(), Optional("b", default=False): Bool(), })

```



When parsed the result will include the optional value:


```python
Ensure(load(yaml_snippet, schema).data).equals(OrderedDict([("a", 1), ("b", False)]))

```




If parsed and then output to YAML again the default data won't be there:


```python
print(load(yaml_snippet, schema).as_yaml())
```

```yaml
a: 1
```




When default data is output to YAML it is removed:


```python
print(as_document({"a": 1, "b": False}, schema).as_yaml())

```

```yaml
a: 1
```




When you want a key to stay and default to None:


```python
schema = Map({"a": Int(), Optional("b", default=None, drop_if_none=False): EmptyNone() | Bool(), })
Ensure(load(yaml_snippet, schema).data).equals(OrderedDict([("a", 1), ("b", None)]))

```







## Recording the effective configuration

Use `include_defaults=True` to write all validated optional defaults, including
defaults inside nested mappings and sequence items. This is useful for
recording the complete configuration used by an execution:

```python
configuration = load(yaml_snippet, schema)
print(configuration.as_yaml(include_defaults=True))
```

```yaml
a: 1
b: no
```

The same option works on documents created with `as_document()` and on
`as_marked_up()` when using your own dumper. It preserves existing comments
and the spelling of explicit values. Implicit keys are appended in schema
order; optionals without defaults remain absent. No extra comments are added.

The expanded result is a copy: `configuration.as_yaml()` still returns the
original markup, and neither the schema nor the validated values are changed.
The default remains `include_defaults=False`.

!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/optional-with-defaults.story">optional-with-defaults.story
    storytests.
