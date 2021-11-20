---
title: Design Justifications
---

StrictYAML is the result of some carefully considered, although
controversial design decisions. These are justified here.

{% for dirfile in (thisdir.is_not_dir() - thisdir.named("index.md"))|sort() -%}
- [{{ title(dirfile) }}]({{ dirfile.name.splitext()[0] }})
{% endfor %}

If you have seen a relevant counterargument to you'd like to link
to addressed at StrictYAML, please create a pull request and
link to it in the relevant document.

If you'd like to write your own rebuttal to any argument raised
here, raise a ticket and issue a pull request linking to it at
the end of the document.
