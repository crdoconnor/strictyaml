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

Explicit typecasts in YAML markup are not only ugly, they confuse non-programmers. StrictYAML's philosophy is that type information should be kept strictly separated from data, so this 'feature' of YAML is switched off.

If data like this is seen in a YAML file it will raise a special exception.
