---
title: Dirty load
type: using
---


StrictYAML refuses to parse flow style and node anchors
by default, but since there have since been
[some requests](https://github.com/crdoconnor/strictyaml/issues/38)
to parse flow style, this now allowed with the "dirty_load" method.
If allow_flow_style is True, Map indentation is not checked for
consistency, as the indentation level is dependent on the map key length.




```python
from strictyaml import Map, Int, MapPattern, Seq, Str, Any, dirty_load

schema = Map({"foo": Map({"a": Any(), "b": Any(), "c": Any()}), "y": MapPattern(Str(), Str()), "z": Seq(Str())})

```



Flow style mapping:

```yaml
foo: { a: 1, b: 2, c: 3 }
y: {}
z: []

```


```python
assert dirty_load(yaml_snippet, schema, allow_flow_style=True) == {"foo": {"a": "1", "b": "2", "c": "3"}, "y": {}, "z": []}

```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/dirty-load.story">dirty-load.story</a>.
{{< /note >}}