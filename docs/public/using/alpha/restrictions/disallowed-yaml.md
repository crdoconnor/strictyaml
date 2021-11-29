---
title: Disallowed YAML
---


StrictYAML parses an opinionated subset of the YAML
specification which refuses to parse features which
are otherwise valid in standard YAML.

For an explanation as to why these features are stripped
out of StrictYAML, see the FAQ.

Disallowed YAML features raise Disallowed exceptions
while syntactically invalid YAML raises ScannerError
or ComposerError.

Every error inherits from YAMLError.




```python
from strictyaml import Map, Int, Any, load
from strictyaml import TagTokenDisallowed, FlowMappingDisallowed, AnchorTokenDisallowed

schema = Map({"x": Map({"a": Any(), "b": Any(), "c": Any()})})

```



Tag tokens:

```yaml
x:
  a: !!str yes
  b: !!str 3.5
  c: !!str yes

```


```python
load(yaml_snippet, schema, label="disallowed")
```


```python
strictyaml.exceptions.TagTokenDisallowed:
While scanning
  in "disallowed", line 2, column 11:
      a: !!str yes
              ^ (line: 2)
Found disallowed tag tokens (do not specify types in markup)
  in "disallowed", line 2, column 6:
      a: !!str yes
         ^ (line: 2)
```




Flow style sequence:

```yaml
[a, b]: [x, y]

```


```python
load(yaml_snippet, schema, label="disallowed")
```


```python
strictyaml.exceptions.FlowMappingDisallowed:
While scanning
  in "disallowed", line 1, column 1:
    [a, b]: [x, y]
    ^ (line: 1)
Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
  in "disallowed", line 1, column 2:
    [a, b]: [x, y]
     ^ (line: 1)
```




Flow style mapping:

```yaml
x: { a: 1, b: 2, c: 3 }

```


```python
load(yaml_snippet, schema, label="disallowed")
```


```python
strictyaml.exceptions.FlowMappingDisallowed:
While scanning
  in "disallowed", line 1, column 4:
    x: { a: 1, b: 2, c: 3 }
       ^ (line: 1)
Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
  in "disallowed", line 1, column 5:
    x: { a: 1, b: 2, c: 3 }
        ^ (line: 1)
```




Node anchors and references:

```yaml
x: 
  a: &node1 3.5
  b: 1
  c: *node1

```


```python
load(yaml_snippet, schema, label="disallowed")
```


```python
strictyaml.exceptions.AnchorTokenDisallowed:
While scanning
  in "disallowed", line 2, column 6:
      a: &node1 3.5
         ^ (line: 2)
Found confusing disallowed anchor token (surround with ' and ' to make text appear literally)
  in "disallowed", line 2, column 12:
      a: &node1 3.5
               ^ (line: 2)
```




Syntactically invalid YAML:

```yaml
- invalid
string

```


```python
load(yaml_snippet, schema, label="disallowed")
```


```python
strictyaml.ruamel.scanner.ScannerError:
while scanning a simple key
  in "disallowed", line 2, column 1:
    string
    ^ (line: 2)
could not find expected ':'
  in "disallowed", line 3, column 1:
    
    ^ (line: 3)
```




Mixed space indentation:

```yaml
item:
  two space indent: 2
item two:
    four space indent: 2

```


```python
load(yaml_snippet, label="disallowed")
```


```python
strictyaml.exceptions.InconsistentIndentationDisallowed:
While parsing
  in "disallowed", line 4, column 5:
        four space indent: 2
        ^ (line: 4)
Found mapping with indentation inconsistent with previous mapping
  in "disallowed", line 5, column 1:
    
    ^ (line: 5)
```







!!! note "Executable specification"

    Documentation automatically generated from 
    <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/disallow.story">disallow.story
    storytests.