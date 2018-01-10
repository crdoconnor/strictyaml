Should I use kwalify?
---------------------

Kwalify is a schema validation language that is written *in* YAML.

It is a descriptive schema language suitable for validating simple YAML.

Kwalify compiles to the strictyaml equivalent but is able to do less. You cannot, for example:

* Plug generated lists that come from outside of the spec (e.g. a list of country code from pycountry).
* Validate parts of the schema which can be either one thing *or* another - e.g. a list *or* a single string.
* Plug sub-validators of a document into larger validators.

If your schema is very simple and small, there is no point to using kwalify.

If your schema needs to be shared with a 3rd party - especially a third party using another language, it may be helpful to use it.

If your schema validation requirements are more complicated - e.g. like what is described above - it's best *not* to use it.


Why not use pykwalify to validate YAML instead?
-----------------------------------------------

See the question above for the correct times to use kwalify to validate your code and crucially, when not to.
