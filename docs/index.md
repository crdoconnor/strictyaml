{% if readme -%}
# StrictYAML
{%- else -%}
---
title: StrictYAML
---

{% raw %}{{< github-stars user="crdoconnor" project="strictyaml" >}}{% endraw %}
{% endif %}

StrictYAML is a [type-safe](https://en.wikipedia.org/wiki/Type_safety) YAML parser
that parses and validates a [restricted subset](features-removed) of the [YAML](what-is-yaml)
specification.

Priorities:

- Beautiful API
- Refusing to parse [the ugly, hard to read and insecure features of YAML](features-removed).
- Strict validation of markup and straightforward type casting.
- Clear, readable exceptions with **code snippets** and **line numbers**.
- Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
- Ability to read in YAML, make changes and write it out again with comments preserved.
- [Not speed](why/speed-not-a-priority), currently.

{% for story in quickstart %}
{{ story.name }}:
{% if 'yaml_snippet' in story.data['given'] %}
```yaml
{{ story.given['yaml_snippet'] }}
```
{% endif %}
{% if 'setup' in story.data['given'] %}
```python
{{ story.given['setup'] }}
```
{% endif %}


{% for variation in story.variations %}

{{ variation.child_name }}:

{% with step = variation.steps[0] %}{% include "step.jinja2" %}{% endwith %}
{% endfor %}
{% endfor %}

## Install

```sh
$ pip install strictyaml
```

## Why StrictYAML?

There are a number of formats and approaches that can achieve more or
less the same purpose as StrictYAML. I've tried to make it the best one.
Below is a series of documented justifications:


{% for dirfile in subdir("why-not").is_not_dir() - subdir("why-not").named("index.md") -%} 
- [{{ title(dirfile) }}](why-not/{{ dirfile.namebase }})
{% endfor %}


## Using StrictYAML

How to:

{% for dirfile in subdir("using/alpha/howto/").is_not_dir() - subdir("using/alpha/howto/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/howto/{{ dirfile.namebase }})
{% endfor %}

Compound validators:

{% for dirfile in subdir("using/alpha/compound/").is_not_dir() - subdir("using/alpha/compound/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/compound/{{ dirfile.namebase }})
{% endfor %}

Scalar validators:

{% for dirfile in subdir("using/alpha/scalar/").is_not_dir() - subdir("using/alpha/scalar/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/scalar/{{ dirfile.namebase }})
{% endfor %}

Restrictions:

{% for dirfile in subdir("using/alpha/restrictions/").is_not_dir() - subdir("using/alpha/restrictions/").named("index.md") -%}
- [{{ title(dirfile) }}](using/alpha/restrictions/{{ dirfile.namebase }})
{% endfor %}

## Design justifications

There are some design decisions in StrictYAML which are controversial
and/or not obvious. Those are documented here:

{% for dirfile in subdir("why").is_not_dir() - subdir("why").named("index.md") -%}
- [{{ title(dirfile) }}](why/{{ dirfile.namebase }})
{% endfor %}

## Contributors

- @gvx
- @AlexandreDecan
- @lots0logs
- @tobbez

## Contributing

* Before writing any code, please read the tutorial on [contributing to hitchdev libraries](https://hitchdev.com/approach/contributing-to-hitch-libraries/).

* Before writing any code, if you're proposing a new feature, please raise it on github. If it's an existing feature / bug, please comment and briefly describe how you're going to implement it.

* All code needs to come accompanied with a story that exercises it or (more typically), a modification to an existing story. This is used both to test the code and build the documentation.


