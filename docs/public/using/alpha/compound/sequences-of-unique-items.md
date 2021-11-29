---
title: Sequences of unique items (UniqueSeq)
---


UniqueSeq validates sequences which contain no duplicate
values.


Example yaml_snippet:

```yaml
- A
- B
- C

```


```python
from strictyaml import UniqueSeq, Str, load, as_document
from ensure import Ensure

schema = UniqueSeq(Str())

```



Valid:


```python
Ensure(load(yaml_snippet, schema)).equals(["A", "B", "C", ])

```




Parsing with one dupe raises an exception:

```yaml
- A
- B
- B

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a sequence
  in "<unicode string>", line 1, column 1:
    - A
     ^ (line: 1)
duplicate found
  in "<unicode string>", line 3, column 1:
    - B
    ^ (line: 3)
```




Parsing all dupes raises an exception:

```yaml
- 3
- 3
- 3

```


```python
load(yaml_snippet, schema)
```


```python
strictyaml.exceptions.YAMLValidationError:
while parsing a sequence
  in "<unicode string>", line 1, column 1:
    - '3'
     ^ (line: 1)
duplicate found
  in "<unicode string>", line 3, column 1:
    - '3'
    ^ (line: 3)
```




Serializing with dupes raises an exception:


```python
as_document(["A", "B", "B"], schema)

```


```python
strictyaml.exceptions.YAMLSerializationError:
Expecting all unique items, but duplicates were found in '['A', 'B', 'B']'.
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/unique-sequence.story">unique-sequence.story
    storytests.