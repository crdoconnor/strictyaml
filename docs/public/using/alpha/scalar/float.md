---
title: Floating point numbers (Float)
---


StrictYAML parses to a YAML object representing
a decimal - e.g. YAML(1.0000000000000001)

To get a python float literal, use .data.

Parsing and validating as a Decimal is best for
values which require precision, but float is better
for values for which precision is not required.


Example yaml_snippet:

```yaml
a: 1.00000000000000000001
b: 5.4135

```


```python
from math import isnan, isinf

from strictyaml import Map, MapPattern, Str, Float, Bool, load, as_document
from collections import OrderedDict
from ensure import Ensure

schema = Map({"a": Float(), "b": Float()})

```



Use .data to get float type:


```python
Ensure(type(load(yaml_snippet, schema)["a"].data)).equals(float)

```




Equal to equivalent float which is different number:


```python
Ensure(load(yaml_snippet, schema)).equals({"a": 1.0, "b": 5.4135})

```




Cast to str:


```python
Ensure(str(load(yaml_snippet, schema)["a"])).equals("1.0")

```




Cast to float:


```python
Ensure(float(load(yaml_snippet, schema)["a"])).equals(1.0)

```




Greater than:


```python
Ensure(load(yaml_snippet, schema)["a"] > 0).is_true()

```




Less than:


```python
Ensure(load(yaml_snippet, schema)["a"] < 0).is_false()

```




Has NaN values:

```yaml
a: nan
b: .NaN

```


```python
Ensure(isnan(load(yaml_snippet, schema)["a"].data)).is_true()
Ensure(isnan(load(yaml_snippet, schema)["b"].data)).is_true()

```




Has infinity values:

```yaml
a: -.Inf
b: INF

```


```python
Ensure(isinf(load(yaml_snippet, schema)["a"].data)).is_true()
Ensure(isinf(load(yaml_snippet, schema)["b"].data)).is_true()

```




Has underscores:

```yaml
a: 10_000_000.5
b: 10_0_0.2_5

```


```python
Ensure(load(yaml_snippet, schema).data).equals({"a": 10000000.5, "b": 1000.25})

```




Cannot cast to bool:


```python
bool(load(yaml_snippet, schema)['a'])
```


```python
:
Cannot cast 'YAML(1.0)' to bool.
Use bool(yamlobj.data) or bool(yamlobj.text) instead.
```




Cannot parse non-float:

```yaml
a: string
b: 2

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a float
found arbitrary text
  in "<unicode string>", line 1, column 1:
    a: string
     ^ (line: 1)
```




Serialize successfully:


```python
print(as_document(OrderedDict([("a", 3.5), ("b", "2.1")]), schema).as_yaml())
```

```yaml
a: 3.5
b: 2.1
```




Serialize successfully with NaN:


```python
print(as_document(OrderedDict([("a", 3.5), ("b", float("nan"))]), schema).as_yaml())
```

```yaml
a: 3.5
b: nan
```




Serialize successfully with infinity:


```python
print(as_document(OrderedDict([("a", float("inf")), ("b", float("-inf"))]), schema).as_yaml())
```

```yaml
a: inf
b: -inf
```




Serialization failure:


```python
as_document(OrderedDict([("a", "x"), ("b", "2.1")]), schema)
```


```python
strictyaml.exceptions.YAMLSerializationError:
when expecting a float, got 'x'
```




Float as key:


```python
document = as_document(OrderedDict([("3.5", "a"), ("2.1", "c")]), MapPattern(Float(), Str()))
print(document.data[3.5])
print(document.data[2.1])

```

```yaml
a
c
```




Float or bool:


```python
document = as_document({"a": True}, Map({"a": Float() | Bool()}))
print(document.as_yaml())

```

```yaml
a: yes
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/float.story">float.story
    storytests.