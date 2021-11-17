---
title: Labeling exceptions
type: using
---


When raising exceptions, you can add a label that will replace
<unicode string> with whatever you want.


Example yaml_snippet:

```yaml
a: 1
b:
  - 1
  - 2

```


```python
from strictyaml import Map, Int, load, YAMLValidationError

```



Label myfilename:


```python
load(yaml_snippet, Map({"a": Int(), "b": Map({"x": Int(), "y": Int()})}), label="myfilename")

```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a mapping
  in "myfilename", line 2, column 1:
    b:
    ^ (line: 2)
found a sequence
  in "myfilename", line 4, column 1:
    - '2'
    ^ (line: 4)
```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/handle-exceptions.story">handle-exceptions.story</a>.
{{< /note >}}