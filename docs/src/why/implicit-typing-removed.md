---
title: The Norway Problem - why StrictYAML refuses to do implicit typing and so should you
---

A while back I met an old coworker and he started telling me about this
interesting bug he faced:

"So, we started internationalizing the website by creating a config
file. We added the UK, Ireland, France and Germany at first."

```yaml
countries:
- GB
- IE
- FR
- DE
```

"This was all fine. However, one day after a quick configuration change
all hell broke loose. It turned out that while the UK, France and
Germany were all fine, *Norway* was *not*..."

"While the website went down and we were losing money we chased down
a number of loose ends until finally finding the root cause."

"If turned out that if feed this configuration file into
[pyyaml](http://pyyaml.org):"

```yaml
countries:
- GB
- IE
- FR
- DE
- NO
```

"This is what you got in return:"

```python
>>> from pyyaml import load
>>> load(the_configuration)
{'countries': ['GB', 'IE', 'FR', 'DE', False]}
```

It snows a *lot* in False.

When this is fed to code that expects a string of the form 'NO',
then the code will usually break, often with a cryptic error,
Typically it would be a KeyError when trying to use 'False'
as a key in a dict when no such key exists.

It can be "quick fixed" by using quotes - a fix for sure, but
kind of a hack - and by that time the damage is done:

```yaml
countries:
- GB
- IE
- FR
- DE
- 'NO'
```

The most tragic aspect of this bug, however, is that it is
*intended* behavior according to the [YAML 1.2 specification](https://yaml.org/spec/1.2.2/).
The real fix requires explicitly disregarding the spec - which
is why most YAML parsers have it.

StrictYAML sidesteps this problem by ignoring key parts of the
spec, in an attempt to create a "zero surprises" parser.

*Everything* is a string by default:

```python
>>> from strictyaml import load
>>> load(the_configuration).data
{'countries': ['GB', 'IE', 'FR', 'DE', 'NO']}
```


## String or float?

Norway is just the tip of the iceberg. The first time this problem hit me
I was maintaining a configuration file of application versions. I had
a file like this initially - which caused no issues:

```yaml
python: 3.5.3
postgres: 9.3.0
```

However, if I changed it *very* slightly:

```yaml
python: 3.5.3
postgres: 9.3
```

I started getting type errors because it was parsed like this:

```python
>>> from ruamel.yaml import load
>>> load(versions) == [{"python": "3.5.3", "postgres": 9.3}]    # oops those *both* should have been strings
```

Again, this led to type errors in my code. Again, I 'quick fixed' it with quotes.
However, the solution I really wanted was:

```python
>>> from strictyaml import load
>>> load(versions) == [{"python": "3.5.3", "postgres": "9.3"}]    # that's better
```


## The world's most buggy name

[Christopher Null](http://www.wired.com/2015/11/null) has a name that is
notorious for breaking software code - airlines, banks, every bug caused
by a programmer who didn't know a type from their elbow has hit him.

YAML, sadly, is no exception:

```yaml
first name: Christopher
surname: Null
```

```python
# Is it okay if we just call you Christopher None instead?
>>> load(name) == {"first name": "Christopher", "surname": None}
```

With StrictYAML:

```python
>>> from strictyaml import load
>>> load(name) == {"first name": "Christopher", "surname": "Null"}
```


## Type theoretical concerns

Type theory is a popular topic with regards to programming languages,
where a well designed type system is regarded (rightly) as a yoke that
can catch bugs at an early stage of development while *poorly*
designed type systems provide fertile breeding ground for edge case
bugs.

(it's equally true that extremely strict type systems require a lot
more upfront and the law of diminishing returns applies to type
strictness - a cogent answer to the question "why is so little
software written in haskell?").

A less popular, although equally true idea is the notion that markup
languages like YAML have the same issues with types - as demonstrated
above.


## User Experience

In a way, type systems can be considered both a mathematical concern
and a UX device.

In the above, and in most cases, implicit typing represents a major violation
of the UX [principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment).
