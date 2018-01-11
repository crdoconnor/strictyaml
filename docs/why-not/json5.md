---
title: Why not JSON5?
---

[JSON5](http://json5.org/) is also a proposed extension to JSON to make it more readable.

Its main criticism of YAML is::

  There are other formats that are human-friendlier, like YAML, but changing from JSON to a completely different format is undesirable in many cases.

This is, I belive, mistaken. It is better if a language is not subtly different if you are going to use it as such. Subtle differences invite mistakes brought on by confusion.

JSON5 looks like a hybrid of YAML and JSON::

```json
{
    foo: 'bar',
    while: true,
}
```

It has weaknesses similar to TOML:

- The noisiness of the delimiters that supplant significant whitespace make it less readable and editable.
- The use of [syntax typing](../../why/syntax-typing-bad) is neither necessary, nor an aid to stricter typing if you have a schema.
