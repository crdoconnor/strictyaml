---
title: Why not X?
---

There are a number of formats and approaches that can achieve more or
less the same purpose as StrictYAML. Below is a series of comparisons
with some of the more famous ones:

{% for dirfile in (thisdir.ext("md") - thisdir.named("index.md"))|sort() -%}
- [{{ title(dirfile) }}]({{ dirfile.namebase }})
{% endfor %}

If you'd like to write or link to a rebuttal to any argument raised
here, feel free to raise a ticket.
