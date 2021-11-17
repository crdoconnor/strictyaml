---
title: Scalar StrictYAML Validators
---

{% for dirfile in thisdir.is_not_dir() - thisdir.named("index.md") -%}
- [{{ title(dirfile) }}]({{ dirfile.namebase }})
{% endfor %}
