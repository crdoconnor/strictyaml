---
title: How to...
---

{% for dirfile in subdir("using/alpha/howto/").is_not_dir() - subdir("using/alpha/howto/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/howto/{{ dirfile.namebase }})
{% endfor %}
