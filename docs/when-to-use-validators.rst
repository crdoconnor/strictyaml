When should I use a validator and when should I not?
----------------------------------------------------

When starting out on greenfield projects it's much quicker not to create a validator. In such cases it's often more prudent to just parse the YAML and convert the strings explicitly on the fly (e.g. int(yaml['key'])).

If the YAML is also going to be largely under the control of the developer it also might not make sense to write a validator either.

If you have written software that is going to parse YAML from a source you do *not* control - especially by somebody who might make a mistake - then it probably does make sense to write a validator.

You can start off without using a validator and then add one later.
