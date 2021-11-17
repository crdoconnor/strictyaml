---
title: Mappings with arbitrary key names (MapPattern)
type: using
---


When you do not wish to let the user define the key
names in a mapping and and only specify what type the
keys are, use a MapPattern.

When you wish to specify the exact key name, use the
'Map' validator instead.




```python
from strictyaml import MapPattern, Int, Float, Str, Any, Seq, YAMLValidationError, load
from ensure import Ensure

schema = MapPattern(Str(), Int())

```



Equivalence 1:

```yaml
â: 1
b: 2

```


```python
Ensure(load(yaml_snippet, schema)).equals({u"â": 1, "b": 2})

```




Equivalence 2:

```yaml
a: 1
c: 3

```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1, "c": 3})

```




Equivalence 3:

```yaml
a: 1

```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1, })

```




With floats and ints:

```yaml
10.25: 23
20.33: 76

```


```python
Ensure(load(yaml_snippet, MapPattern(Float(), Int())).data).equals({10.25: 23, 20.33: 76})

```




With Int and List:

```yaml
1:
- ABC
2:
- DEF

```


```python
Ensure(load(yaml_snippet, MapPattern(Int(), Seq(Str()))).data).equals({1: ["ABC"], 2: ["DEF"]})

```




Invalid 1:

```yaml
b: b

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found arbitrary text
  in "<unicode string>", line 1, column 1:
    b: b
     ^ (line: 1)
```




Invalid 2:

```yaml
a: a
b: 2

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found arbitrary text
  in "<unicode string>", line 1, column 1:
    a: a
     ^ (line: 1)
```




More than the maximum number of keys:

```yaml
â: 1
b: 2

```


```python
load(yaml_snippet, MapPattern(Str(), Int(), maximum_keys=1))
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
  in "<unicode string>", line 1, column 1:
    "\xE2": '1'
     ^ (line: 1)
expected a maximum of 1 key, found 2.
  in "<unicode string>", line 2, column 1:
    b: '2'
    ^ (line: 2)
```




Fewer than the minimum number of keys:

```yaml
â: 1

```


```python
load(yaml_snippet, MapPattern(Str(), Int(), minimum_keys=2))
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
expected a minimum of 2 keys, found 1.
  in "<unicode string>", line 1, column 1:
    "\xE2": '1'
     ^ (line: 1)
```




Invalid with non-ascii:

```yaml
a: 1
b: yâs
c: 3

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found arbitrary text
  in "<unicode string>", line 2, column 1:
    b: "y\xE2s"
    ^ (line: 2)
```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/mappattern.story">mappattern.story</a>.
{{< /note >}}