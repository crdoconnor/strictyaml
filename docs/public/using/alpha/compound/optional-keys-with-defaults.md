---
title: Optional keys with defaults (Map/Optional)
type: using
---

{{< warning title="Experimental" >}}
This feature is in alpha. The API may change on a minor version increment.
{{< /warning >}}




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






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/optional-with-defaults.story">optional-with-defaults.story</a>.
{{< /note >}}