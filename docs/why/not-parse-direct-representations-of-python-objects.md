---
title: Why does StrictYAML not parse direct representations of python objects?
---

Regular YAML allows the direct representation of python objects.

For example:

```yaml
--- !python/hash:UserObject
email: evilhacker@hacker.com
password: passwordtoset
type: admin
```

If we load this YAML formatted string in, we get a user object. This was
how YAML was intended to work since it allows the ability to write objects
to and read them from, say, a database.

By itself, this behavior isn't necessarily capable of enacting a successful
attack, so not all code that parses untrusted YAML is insecure,
but it can be used, especially when metaprogramming is used to execute
arbitrary code on your system.

This shares a lot in common with the pickle module's behavior, which is why
its use with [untrusted input is strongly recommended against in the python
docs](https://docs.python.org/3/library/pickle.html).

This anti-feature led to Ruby on Rails' spectacular [security fail](https://codeclimate.com/blog/rails-remote-code-execution-vulnerability-explained/).
