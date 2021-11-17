---
title: What is wrong with explicit tags?
---

Explicit tags are tags that have an explicit type attached that is used to determine what type to convert the data to when it is parsed.

For example, if it were to be applied to "fix" the Godfather movie script parsing issue described above, it would look like this:

```yaml
- Don Corleone: Do you have faith in my judgment?
- Clemenza: !!str Yes
- Don Corleone: Do I have your loyalty?
```

Explicit typecasts in YAML markup are slightly confusing for non-programmers, much like the concept of 'types' in general. StrictYAML's philosophy is that types should be kept strictly separated from data, so this 'feature' of YAML is switched off.

If tags are seen in a YAML file it will raise a special TagTokenDisallowed exception.


## Counterpoints

- [Valid usage in AWS cloudformation syntax?](https://github.com/crdoconnor/strictyaml/issues/37)
