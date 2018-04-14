{% if readme -%}
StrictYAML
==========
{%- else -%}
---
title: StrictYAML
---

{% raw %}{{< github-stars user="crdoconnor" project="strictyaml" >}}{% endraw %}
{% endif %}

StrictYAML is a [type-safe](https://en.wikipedia.org/wiki/Type_safety) YAML parser
that parses a [restricted subset](features-removed) of the [YAML](what-is-yaml)
specificaton.

Priorities:

- Beautiful API
- Refusing to parse [the ugly, hard to read and insecure features of YAML](features-removed).
- Strict validation of markup and straightforward type casting.
- Clear, readable exceptions with **code snippets** and **line numbers**.
- Acting as a near-drop in replacement for pyyaml, ruamel.yaml or poyo.
- Ability to read in YAML, make changes and write it out again with comments preserved.
- [Not speed](why/speed-not-a-priority), currently.

{% for story in quickstart %}
{{ story.documentation(template="readme") }}
{% endfor %}

Install
-------

```sh
$ pip install strictyaml
```

Why StrictYAML?
---------------

There are a number of formats and approaches that can achieve more or
less the same purpose as StrictYAML. I've tried to make it the best one.
Below is a series of documented justifications:


{% for link in why_not -%}
- [{{ link['name'] }}]({{ link['slug'] }})
{% endfor %}


Using StrictYAML
----------------

{% for category, content in using_categories['using']['alpha'].items() -%}
- [{{ category }}](using/alpha/{{ category }})
{% for link in content.values() %}
  - [{{ link['name'] }}]({{ link['slug'] }})
{% endfor%}
{% endfor %}


Design justifications
---------------------

There are some design decisions in StrictYAML which are controversial
and/or not obvious. Those are documented here:

{% for link in why -%}
- [{{ link['name'] }}]({{ link['slug'] }})
{% endfor %}

Breaking changes
----------------

0.5: Data is now parsed by default as a YAML object instead of directly to dict/list. To get dict/list and ordinary values as before, get yaml_object.data.

Contributors
------------

- @gvx
- @AlexandreDecan
- @lots0logs
- @tobbez

