---
title: Why not use SDLang?
---

[SDLang](http://sdlang.org/) or "simple declarative language" is a proposed configuration language with an XML-like structure inspired by C.

Example:

```
// This is a node with a single string value
title "Hello, World"

// Multiple values are supported, too
bookmarks 12 15 188 1234

// Nodes can have attributes
author "Peter Parker" email="peter@example.org" active=true

// Nodes can be arbitrarily nested
contents {
    section "First section" {
        paragraph "This is the first paragraph"
        paragraph "This is the second paragraph"
    }
}

// Anonymous nodes are supported
"This text is the value of an anonymous node!"

// This makes things like matrix definitions very convenient
matrix {
    1 0 0
    0 1 0
    0 0 1
}
```

Advantages:

- Relatively more straightforward than other serialization languages.

Disadvantages:

- Syntax typing - leading to noisy syntax.
- The distinction between properties and values is not entirely clear.
- Instead of having one obvious way to describe property:value mappings
- Niche
