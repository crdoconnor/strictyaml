---
title: Validating strings with regexes (Regex)
type: using
---


StrictYAML can validate regular expressions and return a
string. If the regular expression does not match, an
exception is raised.




```python
from strictyaml import Regex, Map, load, as_document
from collections import OrderedDict
from ensure import Ensure

schema = Map({"a": Regex(u"[1-4]"), "b": Regex(u"[5-9]")})

```



Parsed correctly:

```yaml
a: 1
b: 5

```


```python
Ensure(load(yaml_snippet, schema)).equals({"a": "1", "b": "5"})

```




Non-matching:

```yaml
a: 5
b: 5

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting string matching [1-4]
found non-matching string
  in "<unicode string>", line 1, column 1:
    a: '5'
     ^ (line: 1)
```




Non-matching suffix:

```yaml
a: 1 Hello
b: 5

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting string matching [1-4]
found non-matching string
  in "<unicode string>", line 1, column 1:
    a: 1 Hello
     ^ (line: 1)
```




Serialized successfully:


```python
print(as_document(OrderedDict([("a", "1"), ("b", "5")]), schema).as_yaml())

```

```yaml
a: 1
b: 5
```




Serialization failure non matching regex:


```python
as_document(OrderedDict([("a", "x"), ("b", "5")]), schema)

```


```python
strictyaml.exceptions.YAMLSerializationError:
when expecting string matching [1-4] found 'x'
```




Serialization failure not a string:


```python
as_document(OrderedDict([("a", 1), ("b", "5")]), schema)

```


```python
strictyaml.exceptions.YAMLSerializationError:
when expecting string matching [1-4] got '1' of type int.
```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/regexp.story">regexp.story</a>.
{{< /note >}}