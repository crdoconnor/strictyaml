---
title: Hexadecimal Integers (HexInt)
type: using
---


StrictYAML can interpret a hexadecimal integer
preserving its value 


Example yaml_snippet:

```yaml
x: 0x1a

```


```python
from strictyaml import Map, HexInt, load
from ensure import Ensure

schema = Map({"x": HexInt()})

parsed = load(yaml_snippet, schema)

```



Parsed correctly:


```python
Ensure(parsed).equals({"x": 26})
Ensure(parsed.as_yaml()).equals("x: 0x1a\n")

```




Uppercase:

```yaml
x: 0X1A

```


```python
Ensure(load(yaml_snippet, schema).data).equals({"x": 26})
Ensure(load(yaml_snippet, schema).as_yaml()).equals("x: 0X1A\n")

```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/scalar-hexadecimal-integer.story">scalar-hexadecimal-integer.story</a>.
{{< /note >}}