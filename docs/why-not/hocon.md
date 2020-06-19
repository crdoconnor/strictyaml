---
title: Why not HOCON?
---

[HOCON](https://github.com/typesafehub/config/blob/master/HOCON.md) is another "redesigned" JSON, ironically enough, taking JSON and making it even more complicated.

Along with JSON's [syntax typing](../../why/syntax-typing-bad) - a downside of most non-YAML alternatives, HOCON makes the following mistakes in its design:

- It does not fail loudly on duplicate keys.
- It has a confusing rules for deciding on concatenations and substitutions.
- It has a mechanism for substitutions similar to [YAML's node anchor feature](../why/node-anchors-and-references-removed.md) - which, unless used extremely sparingly, can create confusing markup that, ironically, is *not* human optimized.

In addition, its attempt at using "less pedantic" syntax creates a system of rules which makes the behavior of the parser much less obvious and edge cases more frequent.
