---
title: Updating document with a schema
---


When StrictYAML loads a document with a schema, it checks that future
updates to that document follow the original schema.




```python
import strictyaml as s
from ensure import Ensure

```



GitHub \#72:


```python
doc = s.load('a: 9', s.Map({
  'a': s.Str(),
  s.Optional('b'): s.Int(),
}))
doc['b'] = 9
assert doc['b'] == 9
```




Works on empty mapping:


```python
doc = s.load('', s.EmptyDict() | s.Map({
  'a': s.Int(),
}))
doc['a'] = 9
assert doc['a'] == 9, doc.as_yaml()
```




Works on complex types:


```python
doc = s.load('a: 8', s.Map({'a': s.Int() | s.Float()}))
assert type(doc['a'].data) == int, repr(doc.data)
doc['a'] = '5.'
assert type(doc['a'].data) == float, repr(doc.data)
assert doc['a'] == 5.
```




Will not work on empty sequence:


```python
doc = s.load('', s.EmptyList() | s.Seq(s.Int()))
doc[0] = 9

```


```python
strictyaml.exceptions.YAMLSerializationError:
cannot extend list via __setitem__.  Instead, replace whole list on parent node.
```




Works on map with setting, updating, and then setting multiple keys (regression):


```python
doc = s.load('', s.EmptyDict() | s.MapPattern(
  s.Str(),
  s.EmptyDict() | s.Map({
    s.Optional('b'): s.Seq(s.Int()),
  })
))
doc['a'] = {}
doc['a']['b'] = ['9']
assert doc.data == {'a': {'b': [9]}}, doc.data
assert doc.as_yaml() == 'a:\n  b:\n  - 9\n', doc.as_yaml()
# Second assignment doesn't occur...
doc['a']['b'] = ['9', '10']
assert doc.data == {'a': {'b': [9, 10]}}, doc.data
assert doc.as_yaml() == 'a:\n  b:\n  - 9\n  - 10\n', doc.as_yaml()
# If and only if another node is overwritten.  This was a bug due
# to mismatched _ruamelparsed objects.
doc['b'] = {'b': ['11']}
assert doc['a']['b'].data == [9, 10], doc.data
assert doc['b']['b'].data == [11], doc.data
assert doc.as_yaml() == 'a:\n  b:\n  - 9\n  - 10\nb:\n  b:\n  - 11\n', doc.as_yaml()

```




For empty sequence, must instead assign whole sequence as key:


```python
doc = s.load('a:', s.Map({'a': s.EmptyList() | s.Seq(s.Int())}))
doc['a'] = [1, 2, 3]
assert doc['a'].data == [1, 2, 3], repr(doc.data)
```




Can assign from string:


```python
doc = s.load('a: 9', s.Map({
  'a': s.Str(),
  s.Optional('b'): s.Int(),
}))
doc['b'] = '9'
assert doc['b'] == 9
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/update-with-schema.story">update-with-schema.story
    storytests.