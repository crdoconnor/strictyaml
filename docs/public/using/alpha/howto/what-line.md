---
title: Get line numbers of YAML elements
---


Line numbers, the text of an item and text of surrounding lines
can be grabbed from returned YAML objects - using .start_line,
.end_line, lines(), lines_before(x) and lines_after(x).


Example yaml_snippet:

```yaml
y: p
# Some comment
    
a: |
  x

# Another comment
b: y
c: a

d: b

```


```python
from strictyaml import Map, Str, YAMLValidationError, load
from ensure import Ensure

schema = Map({"y": Str(), "a": Str(), "b": Str(), "c": Str(), "d": Str()})

snippet = load(yaml_snippet, schema)

```



If there is preceding comment for an item the start line includes it:


```python
Ensure(snippet["a"].start_line).equals(3)
Ensure(snippet["d"].start_line).equals(9)

```




If there is a trailing comment the end line includes it:


```python
Ensure(snippet["a"].end_line).equals(6)
Ensure(snippet["d"].end_line).equals(10)

```




You can grab the start line of a key:


```python
Ensure(snippet.keys()[1].start_line).equals(3)

```




Start line and end line of whole snippet:


```python
Ensure(snippet.start_line).equals(1)
Ensure(snippet.end_line).equals(10)

```




Grabbing a line before an item:


```python
Ensure(snippet['a'].lines_before(1)).equals("# Some comment")

```




Grabbing a line after an item:


```python
Ensure(snippet['a'].lines_after(4)).equals("b: y\nc: a\n\nd: b")

```




Grabbing the lines of an item including surrounding comments:


```python
print(load(yaml_snippet, schema)['a'].lines())

```

```yaml
a: |
  x

# Another comment
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/whatline.story">whatline.story
    storytests.