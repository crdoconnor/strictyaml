---
title: How to...
---

{% for dirfile in thisdir.is_not_dir() - thisdir.named("index.md") -%}
- [{{ title(dirfile) }}]({{ dirfile.namebase }})
{% endfor %}
