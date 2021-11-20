---
title: Design Justifications
---

StrictYAML is the result of some carefully considered, although
controversial design decisions. These are justified here.

- [What is wrong with duplicate keys?](duplicate-keys-disallowed)
- [What is wrong with explicit tags?](explicit-tags-removed)
- [What is wrong with flow-style YAML?](flow-style-removed)
- [The Norway Problem - why StrictYAML refuses to do implicit typing and so should you](implicit-typing-removed)
- [What is wrong with node anchors and references?](node-anchors-and-references-removed)
- [Why does StrictYAML not parse direct representations of Python objects?](not-parse-direct-representations-of-python-objects)
- [Why does StrictYAML only parse from strings and not files?](only-parse-strings-not-files)
- [Why is parsing speed not a high priority for StrictYAML?](speed-not-a-priority)
- [What is syntax typing?](syntax-typing-bad)
- [Why does StrictYAML make you define a schema in Python - a Turing-complete language?](turing-complete-schema)


If you have seen a relevant counterargument to you'd like to link
to addressed at StrictYAML, please create a pull request and
link to it in the relevant document.

If you'd like to write your own rebuttal to any argument raised
here, raise a ticket and issue a pull request linking to it at
the end of the document.