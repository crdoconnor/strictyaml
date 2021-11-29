---
title: Parsing comma separated items (CommaSeparated)
---


Comma-separated values can be validated and parsed
using the CommaSeparated validator.

Note that the space following the commas is stripped by
default when parsed.




```python
from strictyaml import CommaSeparated, Int, Str, Map, load, as_document
from ensure import Ensure

int_schema = Map({"a": CommaSeparated(Int())})

str_schema = Map({"a": CommaSeparated(Str())})

```



Parse as int:

```yaml
a: 1, 2, 3

```


```python
Ensure(load(yaml_snippet, int_schema)).equals({"a": [1, 2, 3]})

```




Parse as string:

```yaml
a: 1, 2, 3

```


```python
Ensure(load(yaml_snippet, str_schema)).equals({"a": ["1", "2", "3"]})

```




Parse empty comma separated string:

```yaml
a: 

```


```python
Ensure(load(yaml_snippet, str_schema)).equals({"a": []})

```




Invalid int comma separated sequence:

```yaml
a: 1, x, 3

```


```python
load(yaml_snippet, int_schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
  in "<unicode string>", line 2, column 1:
    
    ^ (line: 2)
found arbitrary text
  in "<unicode string>", line 1, column 1:
    a: 1, x, 3
     ^ (line: 1)
```




Serialize list to comma separated sequence:


```python
print(as_document({"a": [1, 2, 3]}, int_schema).as_yaml())

```

```yaml
a: 1, 2, 3
```




Serialize valid string to comma separated sequence:


```python
print(as_document({"a": "1,2,3"}, int_schema).as_yaml())

```

```yaml
a: 1,2,3
```




Serialize empty list to comma separated sequence:


```python
print(as_document({"a": []}, int_schema).as_yaml())

```

```yaml
a:
```




Serialize invalid string to comma separated sequence:


```python
print(as_document({"a": "1,x,3"}, int_schema).as_yaml())

```


```python
strictyaml.exceptions.YAMLSerializationError:
'x' not an integer.
```




Attempt to serialize neither list nor string raises exception:


```python
as_document({"a": 1}, int_schema)

```


```python
strictyaml.exceptions.YAMLSerializationError:
expected string or list, got '1' of type 'int'
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/commaseparated.story">commaseparated.story
    storytests.