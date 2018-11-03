---
title: The Norway Problem - why StrictYAML won't do implicit typing
---

A while back I met an old coworker for a beer and he started
telling me about this interesting internationalization bug he
faced.

"So, we started internationalizing the website and I added a few
more countries - France, Germany, etc. to the configuration file"

```yaml
countries:
- GB
- IE
- FR
- DE
```

"This was fine for a while. Then eventually we got around to adding
Norway..."

```yaml
countries:
- GB
- IE
- FR
- DE
- NO
```

"and then, suddenly, everything broke..."

The problem here is "implicit typing" - the YAML specification states that
the parser should be 'smart' about the strings that are entered in to it and
attempt to convert them into the relevant types for you.

If you feed any of these in, for example, [pyyaml](http://pyyaml.org) or [Poyo](https://github.com/hackebrot/poyo):

```python
>>> from pyyaml import load
>>> load(the_configuration)
{'countries': ['GB', 'IE', 'FR', 'DE', False]}
```

Needless to say, feeding the boolean "False" to just about any other part
of the program where "NO" was expected will break it, possibly catastrophically.

It can be "quick fixed" by using quotes:

```yaml
countries:
- GB
- IE
- FR
- DE
- 'NO'
```

StrictYAML sidesteps this problem by only *ever* parsing to a string or a data
type explicitly defined by the schema:

```python
>>> from strictyaml import load
>>> load(the_configuration).data
{'countries': ['GB', 'IE', 'FR', 'DE', 'NO']}
```


## String or float?

This isn't just a problem with countries. This problem hit me a while back when
trying to maintain a configuration file of various software versions. I had
a config file like this, which wasn't a problem:

```yaml
python: 3.5.3
postgres: 9.3.0
```

And then, as soon as I changed it *very* slightly:

```yaml
python: 3.5.3
postgres: 9.3
```

I started getting type errors:


```python
>>> from ruamel.yaml import load
>>> load(versions) == [{"python": "3.5.3", "postgres": 9.3}]    # oops those *both* should have been strings
```

Again, it can be 'quick fixed' with quotes, but again, the real fix
is simply not to interpret types at all.

## The world's most buggy name

[Christopher Null](http://www.wired.com/2015/11/null) has a name that is notorious for breaking
software code - airlines, banks, everything. YAML, sadly, is no exception:

```yaml
first name: Christopher
surname: Null
```

```python
# Is it okay if we just call you Christopher None instead?
>>> load(name) == {"first name": "Christopher", "surname": None}
```

## Theory of astonishment

In the above cases, implicit typing represents a major violation of [the principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment).
