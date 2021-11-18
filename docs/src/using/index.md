---
title: Using StrictYAML
---

How to:

{% for dirfile in (subdir("using/alpha/howto/").is_not_dir() - subdir("using/alpha/howto/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/howto/{{ dirfile.namebase }})
{% endfor %}

Compound validators:

{% for dirfile in (subdir("using/alpha/compound/").is_not_dir() - subdir("using/alpha/compound/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/compound/{{ dirfile.namebase }})
{% endfor %}

Scalar validators:

{% for dirfile in (subdir("using/alpha/scalar/").is_not_dir() - subdir("using/alpha/scalar/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/scalar/{{ dirfile.namebase }})
{% endfor %}
Restrictions:

{% for dirfile in (subdir("using/alpha/restrictions/").is_not_dir() - subdir("using/alpha/restrictions/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/restrictions/{{ dirfile.namebase }})
{% endfor %}
