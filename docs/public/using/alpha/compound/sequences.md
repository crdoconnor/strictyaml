---
title: Sequence/list validator (Seq)
type: using
---


Sequences in YAML are denoted by a series of dashes ('-')
and parsed as a list in python.

Validating sequences of a particular type can be done with
the Seq validator, specifying the type.

See also [UniqueSeq](../sequences-of-unique-items) and
[FixedSeq](../fixed-length-sequences) for other types of sequence
validation.


Example yaml_snippet:

```yaml
- 1
- 2
- 3

```


```python
from strictyaml import Seq, Str, Int, load
from ensure import Ensure

```



Valid Parsed:


```python
Ensure(load(yaml_snippet, Seq(Str()))).equals(["1", "2", "3", ])

```




Is sequence:


```python
assert load(yaml_snippet, Seq(Str())).is_sequence()

```




Iterator:


```python
assert [x for x in load(yaml_snippet, Seq(Str()))] == ["1", "2", "3"]

```




Lists of lists:

```yaml
-
  - a
  - b
  - c
-
  - d
  - e
  - f

```


```python
assert load(yaml_snippet, Seq(Seq(Str()))) == [["a", "b", "c"], ["d", "e", "f"]]

```




.text is nonsensical:

```yaml
- â
- 2
- 3

```


```python
load(yaml_snippet, Seq(Str())).text
```


```python
builtins.TypeError:YAML(['â', '2', '3']) is a sequence, has no text value.:
```




Invalid mapping instead:

```yaml
a: 1
b: 2
c: 3

```


```python
load(yaml_snippet, Seq(Str()))
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a sequence
  in "<unicode string>", line 1, column 1:
    a: '1'
     ^ (line: 1)
found a mapping
  in "<unicode string>", line 3, column 1:
    c: '3'
    ^ (line: 3)
```




Invalid nested structure instead:

```yaml
- 2
- 3
- a:
  - 1
  - 2

```


```python
load(yaml_snippet, Seq(Str()))
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting a str
  in "<unicode string>", line 3, column 1:
    - a:
    ^ (line: 3)
found a mapping
  in "<unicode string>", line 5, column 1:
      - '2'
    ^ (line: 5)
```




Invalid item in sequence:

```yaml
- 1.1
- 1.2

```


```python
load(yaml_snippet, Seq(Int()))
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found an arbitrary number
  in "<unicode string>", line 1, column 1:
    - '1.1'
     ^ (line: 1)
```




One invalid item in sequence:

```yaml
- 1
- 2
- 3.4

```


```python
load(yaml_snippet, Seq(Int()))
```


```python
strictyaml.exceptions.YAMLValidationError:
when expecting an integer
found an arbitrary number
  in "<unicode string>", line 3, column 1:
    - '3.4'
    ^ (line: 3)
```






{{< note title="Executable specification" >}}
Page automatically generated from <a href="https://github.com/crdoconnor/strictyaml/blob/master/hitch/story/sequence.story">sequence.story</a>.
{{< /note >}}