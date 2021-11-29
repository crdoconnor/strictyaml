---
title: Build a YAML document from scratch in code
---


YAML documents can be built from combinations of dicts,
lists and strings if no schema is used.




```python
from ensure import Ensure
from strictyaml import as_document
from collections import OrderedDict

# Can also use regular dict if an arbitrary ordering is ok
yaml = as_document(OrderedDict(
    [(u"â", 'yes'), ("b", "hâllo"), ("c", ["1", "2", "3"])]
))

```



Then dump:


```python
print(yaml.as_yaml())
```

```yaml
â: yes
b: hâllo
c:
- 1
- 2
- 3
```




However, any type that is not a string, dict or list cannot be parsed without a schema:


```python
class RandomClass(object):
    def __repr__(self):
        return 'some random object'

as_document({"x": RandomClass()})

```


```python
strictyaml.exceptions.YAMLSerializationError:
'some random object' is not a string
```




Empty dicts also cannot be serialized without a schema:


```python
as_document({'hello': {}})

```


```python
strictyaml.exceptions.YAMLSerializationError:
Empty dicts are not serializable to StrictYAML unless schema is used.
```




Neither can lists:


```python
as_document({'hello': []})

```


```python
strictyaml.exceptions.YAMLSerializationError:
Empty lists are not serializable to StrictYAML unless schema is used.
```




You can grab line numbers from the object that is serialized:


```python
Ensure(yaml.start_line).equals(1)

```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/build-yaml-document-from-scratch.story">build-yaml-document-from-scratch.story
    storytests.