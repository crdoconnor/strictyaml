---
title: Dirty load
---


StrictYAML refuses to parse flow style and node anchors
by default, but since there have since been
[some requests](https://github.com/crdoconnor/strictyaml/issues/38)
to parse flow style, this now allowed with the "dirty_load" method.




```python
from strictyaml import Map, Int, MapPattern, Seq, Str, Any, dirty_load

schema = Map({"x": Map({"a": Any(), "b": Any(), "c": Any()}), "y": MapPattern(Str(), Str()), "z": Seq(Str())})

```



Flow style mapping:

```yaml
x: { a: 1, b: 2, c: 3 }
y: {}
z: []

```


```python
assert dirty_load(yaml_snippet, schema, allow_flow_style=True) == {"x": {"a": "1", "b": "2", "c": "3"}, "y": {}, "z": []}

```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/dirty-load.story">dirty-load.story
    storytests.