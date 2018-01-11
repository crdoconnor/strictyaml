---
title: What is wrong with duplicate keys?
---

Duplicate keys are allowed in regular YAML - as parsed by pyyaml, ruamel.yaml and poyo:

```yaml
x: cow
y: dog
x: bull
```

Not only is it unclear whether x should be "cow" or "bull" (the parser will decide 'bull', but did you know that?),
if there are 200 lines between x: cow and x: bull, a user might very likely change the *first* x and erroneously believe that the resulting value of x has been changed - when it hasn't.

In order to avoid all possible confusion, StrictYAML will simply refuse to parse this and will *only* accept associative arrays where all of the keys are unique. It will throw a DuplicateKeysDisallowed exception.
