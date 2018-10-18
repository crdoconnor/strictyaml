---
title: What YAML features does StrictYAML remove?
---

StrictYAML restricts you from parsing a number of things which
the YAML specification says should be parsed. An issue has
been [raised](https://github.com/yaml/YAML2/issues/8) by
[David Seaward](https://inkwell.za.net/) about this critique
on the official YAML repository.

This document lists those of those features:

## Implicit Typing ([Why?](../why/implicit-typing-removed))

```yaml
x: yes
y: null
```

Example pyyaml/ruamel/poyo:

```python
load(yaml) == {"x": True, "y": None} 
```

Example StrictYAML

```python
load(yaml) == {"x": "yes", "y": "null"}
```

## Direct representations of objects ([Why?](../why/binary-data-removed))

```yaml
--- !python/hash:UnsafeUserObject
email: evilhacker@hacker.com
password: passwordtoset
type: admin
```

Example pyyaml/ruamel:

```python
load(yaml) == {'evil': b'z\xf8\xa5u\xabZ'}
```

Example StrictYAML

```python
raises TagTokenDisallowed
```

## Duplicate Keys Disallowed ([Why?](../why/duplicate-keys-disallowed))

```yaml
x: 1
x: 2
```

Example pyyaml/poyo:

```python
load(yaml) == {'x': 2}
```

Example StrictYAML

```python
raises DuplicateKeysDisallowed
```


## Explicit tags ([Why?](../why/explicit-tags-removed))

```yaml
x: !!int 5
```

Example pyyaml/ruamel/poyo:

```python
load(yaml) == load(yaml) == {"x": 5}
```

Example StrictYAML

```python
raises TagTokenDisallowed
```

## Node anchors and refs ([Why?](node-anchors-and-references-removed))

```yaml
x: &id001
  a: 1
y: *id001
```

Example pyyaml/ruamel/poyo:

```python
load(yaml) == {'x': {'a': 1}, 'y': {'a': 1}}
```

Example StrictYAML

```python
raises NodeAnchorDisallowed
```

To parse the above YAML *literally* in StrictYAML do:

```yaml
x: '&id001'
  a: 1
y: '*id001'
```

## Flow style ([Why?](../why/flow-style-removed))

```yaml
x: 1
b: {c: 3, d: 4}
```

Example pyyaml/ruamel/poyo:

```python
load(yaml) == {'x': 1, 'b': {'c': 3, 'd': 4}}
```

Example StrictYAML

```python
raises FlowStyleDisallowed
```
