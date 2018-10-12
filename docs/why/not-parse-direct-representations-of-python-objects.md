---
title: Why does StrictYAML not parse direct representations of python objects?
---

StrictYAML doesn't allow direct representations of python objects. For example:

```yaml
--- !python/hash:UnsafeUserObject
email: evilhacker@hacker.com
password: passwordtoset
type: admin
```

This anti-feature led to Ruby on Rails' spectacular [security fail](https://www.sitepoint.com/anatomy-of-an-exploit-an-in-depth-look-at-the-rails-yaml-vulnerability/).
