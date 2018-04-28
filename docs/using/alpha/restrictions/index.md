---
title: Restrictions
---

{% for dirfile in subdir("using/alpha/restrictions/").is_not_dir() - subdir("using/alpha/restrictions/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/restrictions/{{ dirfile.namebase }})
{% endfor %}
