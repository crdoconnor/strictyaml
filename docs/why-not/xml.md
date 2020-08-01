---
title: Why not use XML for configuration or DSLs?
---

XML suffers from overcomplication much like vanilla YAML does - although to an ever greater degree, thanks to 
the committee-driven design. Doctypes and namespaces are horrendous additions to the language, for instance. XML is not only not really human readable (beyond a very basic subset of the language), it's often barely *programmer* readable despite being less expressive than most Turing-complete languages. It's a flagrant violation of the [rule of least power](https://en.wikipedia.org/wiki/Rule_of_least_power).

The language was, in fact, *so* overcomplicated that it ended up increasing the attack surface of the parser itself to the point that it led to parsers with [security vulnerabilities](https://en.wikipedia.org/wiki/Billion_laughs).

Unlike JSON and YAML, XML's structure also does not map well on to the default data types used by most languages, often requiring a *third* language to act as a go between - e.g. either XQuery or XPath.

XML's decline in favor of JSON as a default API format is largely due to these complications and the lack of any real benefit drawn from them. The associated technologies (e.g. XSLT) also suffered from design by committee.

Using it as a configuration language will all but ensure that you need to write extra boilerplate code to manage its quirks.
