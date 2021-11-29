---
title: Merge YAML documents
---


Loaded YAML can be combined and dumped with the comments intact.




```python
from strictyaml import Map, MapPattern, Str, Seq, Int, load

schema_1 = Map({
    "a": Str(),
    "b": Map({"x": Int(), "y": Int()}),
    "c": Seq(MapPattern(Str(), Str())),
})

schema_2 = Map({"x": Int(), "y": Int()})

yaml_1 = load(yaml_snippet_1, schema_1)
yaml_2 = load(yaml_snippet_2, schema_2)

yaml_1['b'] = yaml_2

```



```python
print(yaml_1.as_yaml())
```

```yaml
# Some comment

a: â # value comment

# Another comment
b:
  x: 8

# y is now 9
  y: 9
c:
- a: 1
- b: 2
```






!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/merge-documents.story">merge-documents.story
    storytests.