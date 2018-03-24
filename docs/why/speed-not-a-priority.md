---
title: Why is parsing speed not a high priority for StrictYAML?
---

JSON and StrictYAML are essentially complementary formats. They both allow
a relatively loose representation of data that just contains, mappings and
sequences. They are serialization formats that are relatively straightforward
for both humans and machines to read and write.

The main difference is simply one of degree:

JSON is primariliy optimized for *machine* readability and writability, while
still maintaining human readability.

YAML is optimized for *human* readability and writability, while maintaining
machine readability and writability.

This means that the two formats are better suited to slightly different applications.
For instance, JSON is better suited as a format for use with REST APIs while
YAML is better suited as a format for use by configuration languages and DSLs.

If you are using YAML primarily as a readable medium to express a markup language
or represent configuration in, this probably means that 1) what you are reading is
probably relatively short (e.g. < 1,000 lines) and 2) it will be read/written
infrequently (e.g. once, when a program starts).

For this reason, it is assumed that for most StrictYAML applications, parsing
speed is of a lower importance than strictness, readability and ease of use.
