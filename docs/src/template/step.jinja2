{% if step['in_interpreter'] %}
```python
{% for line in step['code'].rstrip('\n').split('\n') %}>>> {{ line }}
{% endfor -%}
{{ step['will_output'] }}
```
{% else %}
```python
{{ step['code'] }}
```
{% if 'will_output' in step %}
```yaml
{{ step['will_output'] }}
```
{% endif %}
{% if 'raises' in step %}
```python
{% if 'in python 3' in step['raises']['type'] -%}
{{ step['raises']['type']['in python 3'] }}:
{%- else %}{{ step['raises']['type'] }}:{% endif -%}
{%- if 'in python 3' in step['raises']['message'] -%}
{{ step['raises']['message']['in python 3']  }}:
```
{% else %}
{{ step['raises']['message'] }}
```
{% endif %}
{% endif %}
{% endif %}
