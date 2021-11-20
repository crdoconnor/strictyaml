---
title: Using StrictYAML
---

How to:

{% for dirfile in (subdir("using/alpha/howto/").is_not_dir() - subdir("using/alpha/howto/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/howto/{{ dirfile.name.splitext()[0] }})
{% endfor %}

Compound validators:

{% for dirfile in (subdir("using/alpha/compound/").is_not_dir() - subdir("using/alpha/compound/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/compound/{{ dirfile.name.splitext()[0] }})
{% endfor %}

Scalar validators:

{% for dirfile in (subdir("using/alpha/scalar/").is_not_dir() - subdir("using/alpha/scalar/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/scalar/{{ dirfile.name.splitext()[0] }})
{% endfor %}
Restrictions:

{% for dirfile in (subdir("using/alpha/restrictions/").is_not_dir() - subdir("using/alpha/restrictions/").named("index.md"))|sort() -%}
- [{{ title(dirfile) }}](alpha/restrictions/{{ dirfile.name.splitext()[0] }})
{% endfor %}
