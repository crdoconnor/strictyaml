---
title: Why not JSON for simple configuration files?
---

JSON is an *ideal* format for REST APIs and other forms of data intended for machine exchange and it probably always will be because:

- It's a simple spec.
- It has all the basic types which map on to all programming languages - number, string, list, mapping, boolean *and no more*.
- Its syntax contains a built in level of error detection - cut a JSON request in half and it is no longer still valid, eliminating an entire class of obscure and problematic bugs.
- If pretty-printed correctly, it's more or less readable - for the purposes of debugging, anyway.

However, while it is eminently suitable for REST APIs it is less suitable for configuration since:

- The same syntax which gives it decent error detection (commas, curly brackets) makes it tricky for humans to edit.
- It's not especially readable.
- It doesn't allow comments.
