---
title: Why not use the YAML 2.0 standard? - we don't need a new standard!
---

![Standards](https://imgs.xkcd.com/comics/standards.png "Fortunately the configuration one has been solved now that we have Strict uh... wait, no it hasn't...")

StrictYAML is composed of two parts:

- A new YAML specification which parses a restricted subset of the YAML 2.0 specification and *only* parses to ordered dict, list or string.
- An optional validator (which will, as requested, validate and cast parse some of those scalar string values to ints, floats, datetimes, etc.).

Note that StrictYAML is *not* a new standard. If you have a syntax highlighter or editor or anything else that recognizes
or reads YAML it will recognize StrictYAML in the same way.

While not all YAML output by other programs will be readable by StrictYAML (it is, after all, stricter), a lot will be.

The features removed from the YAML spec, and their rationales are as follows:

- [Implicit Typing](../../why/implicit-typing-removed)
- [Direct representations of objects](../../why/binary-data-removed)
- [Explicit tags](../../why/explicit-tags-removed)
- [Node anchors and refs](../../why/node-anchors-and-references-removed)
- [Flow style](../../why/flow-style-removed)
- [Duplicate Keys Disallowed](../../why/duplicate-keys-disallowed)

