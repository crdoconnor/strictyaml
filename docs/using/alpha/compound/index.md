---
title: Compound StrictYAML Validators
---

{% for dirfile in subdir("using/alpha/compound/").is_not_dir() - subdir("using/alpha/compound/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/compound/{{ dirfile.namebase }})
{% endfor %}
