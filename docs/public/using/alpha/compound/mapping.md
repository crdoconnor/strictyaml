---
title: Mappings with defined keys (Map)
type: using
---


Mappings of one value to another are represented by : in YAML
and parsed as python dicts.

Using StrictYAML's 'Map' you can validate that a mapping
contains the right keys and the right *type* of values.

Note: for mappings where you don't know the exact names of
the keys in advance but you do know the type, use MapPattern.


Example yaml_snippet:

```yaml
â: 1
b: 2
c: 3

```


```python
from collections import OrderedDict
from strictyaml import Map, Int, load, as_document
from collections import OrderedDict
from ensure import Ensure

schema = Map({"a": Int(), "b": Int(), "c": Int()})

schema_2 = Map({u"â": Int(), "b": Int(), "c": Int()})

```



one key mapping:

```yaml
x: 1
```


```python
Ensure(load(yaml_snippet, Map({"x": Int()})).data).equals(OrderedDict([('x', 1)]))

```




key value:


```python
Ensure(load(yaml_snippet, schema_2)[u'â']).equals(1)

```




get item key not found:


```python
load(yaml_snippet, schema_2)['keynotfound']
```


```python
:
'keynotfound'
```




cannot use .text:


```python
load(yaml_snippet, schema_2).text
```


```python
builtins.TypeError:YAML({'â': 1, 'b': 2, 'c': 3}) is a mapping, has no text value.:
```




parse snippet where key is not found in schema:

```yaml
a: 1
b: 2
â: 3 

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
unexpected key not in schema 'â'
  in "<unicode string>", line 3, column 1:
    "\xE2": '3'
    ^ (line: 3)
```




sequence not expected when parsing:

```yaml
- 1
- 2
- 3 

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a mapping
  in "<unicode string>", line 1, column 1:
    - '1'
     ^ (line: 1)
found a sequence
  in "<unicode string>", line 3, column 1:
    - '3'
    ^ (line: 3)
```




List not expected when serializing:


```python
as_document([1, 2, 3], schema)
```


```python
strictyaml.exceptions.YAMLSerializationError:
Expected a dict, found '[1, 2, 3]'
```




Empty dict not valid when serializing:


```python
as_document({}, schema)
```


```python
strictyaml.exceptions.YAMLSerializationError:
Expected a non-empty dict, found an empty dict.
Use EmptyDict validator to serialize empty dicts.
```




Unexpected key:

```yaml
a: 1
b: 2
c: 3
d: 4

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
unexpected key not in schema 'd'
  in "<unicode string>", line 4, column 1:
    d: '4'
    ^ (line: 4)
```




required key not found:

```yaml
a: 1

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a mapping
required key(s) 'b', 'c' not found
  in "<unicode string>", line 1, column 1:
    a: '1'
     ^ (line: 1)
```




iterator:

```yaml
a: 1
b: 2
c: 3

```


```python
assert [item for item in load(yaml_snippet, schema)] == ["a", "b", "c"]

```




serialize:


```python
assert as_document(OrderedDict([(u"â", 1), ("b", 2), ("c", 3)]), schema_2).as_yaml() == yaml_snippet

```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/map.story">map.story</a>.
{{< /note >}}