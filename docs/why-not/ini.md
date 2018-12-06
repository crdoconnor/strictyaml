---
title: Why not use INI files?
---

INI is a very old and quite readable configuration format for small configuration files.
It is still used by many programs today and it has some advantages due to this - e.g.
python has inbuilt parser for it.

Unfortunately it suffers from two major problems:

- Different parsers will operate in subtly different ways that can lead to often obscure edge case bugs regarding the way whitespace is used, case sensitivity, comments and escape characters.
- It doesn't let you represent hierarchical data.

[TOML](../toml) is a configuration format designed to address these two concerns,
although it also suffers from obscure edge case bugs.
