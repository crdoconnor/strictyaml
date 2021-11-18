---
title: Compound StrictYAML Validators
---

{% for dirfile in (thisdir.is_not_dir() - thisdir.named("index.md"))|sort() -%}
- [{{ title(dirfile) }}]({{ dirfile.namebase }})
{% endfor %}
