---
title: Why not use INI files?
---

INI is a very old and quite readable configuration format. Unfortunately it suffers from two *major* problems:

- Different parsers will operate in subtly different ways that can lead to often obscure bugs regarding the way whitespace is used, case sensitivity, comments and escape characters.
- It doesn't let you represent hierarchical data.

In a way, [TOML](../toml)
