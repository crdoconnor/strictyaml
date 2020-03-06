# Changelog


### Latest

* BUGFIX : Fix accidental python 2 breakage.
* BUGFIX : Accidental misrecognition of boolean values as numbers - cause of #85.
* BUGFIX : Fix for #86 - handle changing multiline strings.
* BUGFIX: handle deprecated collections import in the parser (#82)

* bugfix - handle deprecated collections import in the parser

* import sys


### 1.0.5

* BUGFIX : Fixed python 2 bug introduced when fixing #72.
* BUG: issue #72.  Now __setitem__ uses schema.

Before this commit, schemas could be violated when assigning to
Map/Sequence members.  Now, modifications to the data must fit the
data's schema.

Furthermore, if the node on which __setitem__ is called has a compound
schema, the selected validator within the compound schema may change
correctly.


### 1.0.4

* FEATURE : Include tests / stories in package.
* BUG: issue #72.  Now __setitem__ uses schema.

Before this commit, schemas could be violated when assigning to
Map/Sequence members.  Now, modifications to the data must fit the
data's schema.


### 1.0.3

* BUGFIX : Fix for #64 integer value on YAML object being interpreted as string.


### 1.0.2

* BUGFIX : #63 CommaSeparated should recognize a blank string as a valid empty list.
* BUGFIX : #61 fix for exception when parsing MapPattern with a non-string (float) as a key - hat tip @dgg5503.
* BUGFIX : Fix deprecation warning on Iterable from collections raised by #60 - hat tip @dthonon.
* FEATURE : Raise exception if more than one sequence validators are combined.


### 1.0.1

* FEATURE : #51 - OrValidation with multiple Map validators does not work effectively - raise exception if user tries to use more than one.


### 1.0.0


No relevant code changes.

### 0.15.4

* BUGFIX : If revalidating a subschema with an Or validator and then changing the contents of the parsed data, a cryptic error was raised.


### 0.15.3

* BUGFIX : Fix for #46 - prevent Enum parsed values from becoming YAML objects.


### 0.15.2

* BUGFIX : Modifying YAML via __getitem__ where the YAML was validated using an OR operator failed - or validators didn't have a key_validator.


### 0.15.1

* BUGFIX : Make optional values parsed using Optional appear at the *end* of the ordered dict.
* BUGFIX : Prevent YAML objects from appearing in .data.
* BUGFIX : Fix for bug caused by revalidation with Optional default values.


### 0.15.0

* FEATURE : Raise exception when invalid default data is used is used in Optionals.
* FEATURE : Do not output defaults from Optional() to YAML and ignore parsed defaults where the parsed data is equal to the default specified in Optional().
* BUGFIX : Include README.md.


### 0.14.0

* BUGFIX : Made comma separated serializer serialize correctly.
* BUGFIX : Fixed the way serialization of empty lists, dicts, None and datetimes is handled.
* BUGFIX : Float - fixed transformation in to YAML.
* BUGFIX : Proper serialization for floats.
* BUGFIX : Proper serialization for regexes.
* BUGFIX : Comma separated serialization.
* BUGFIX : Enum - fixed transformation in to YAML.
* BUGFIX : Stricter validation on the serialization of dicts.
* BUGFIX : Stricter validation on the serialization of sequences.
* BUGFIX : Streamlined and fixed the way that serialization of data to YAML is performed so that both complex changes to YAML documents can be made and complex YAML documents can be assembled from scratch.
* BUGFIX : Stop dumping empty dicts / lists.
* BUGFIX : Fixed content encoding on README.


### 0.13.0

* FEATURE : Allow flow style to be parsed with a dirty_load method.


### 0.12.0

* FEATURE : Implement mapping abstract base class as per #39.


### 0.11.10

* BUGFIX : #15 - fix for regression caused by the release of ruamel.yaml 0.15.48.
* FEATURE : Handle building documents a bit more sensibly - build the document from strings, floats, dicts, lists, etc. only.


### 0.11.8

* FEATURE : Include LICENSE.txt in package - #34 - hat tip @mcs07.
* BUGFIX : Fix for #32 hat tip @NoahTheDuke - render given sections on variations in documentation.


### 0.11.7

* FEATURE : Replaced read in README.rst with read in README.md in setup.py.


### 0.11.6

* FEATURE : Replaced link in setup.py to new website.


### 0.11.5

* MINOR BUGFIX : #31 hat tip @karantan - validator was being set incorrectly on YAML objects after parse.


### 0.11.4

* BUGFIX : Fix bug where changing items in the YAML after revalidation failed.


### 0.11.3

* PATCH BUGFIX : Ensure that revalidation keeps the validator.


### 0.11.2

* BUGFIX : When using YAML objects as keys on other YAML objects, it should just use the value.


### 0.11.1

* BUGFIX PATCH : Fix the behavior of getting and deleting items on a YAML object where the key have gone through a validator.
* PATCH BUGFIX : Allow setting of properties using __setitem__ when a key validator was used.
* PATCH REFACTOR : Sequence and Mapping validators now inherit from SeqValidator and MapValidator.
* PATCH REFACTOR : Added some docstrings and removed unnecessary method.
* PATCH REFACTOR : Added docstrings and clarified variable names.
* PATCH REFACTOR : Moved YAMLPointer class into its own file.
* PATCH REFACTOR : Refactored the processing code.
* BUGFIX PATCH : Fix revalidation when using mappings that process keys.
* MINOR : FEATURE : Throw exception on inconsistent indents.
* PATCH : REFACTOR : Cleaned up stories.
* PATCH : REFACTOR : Changes to enable documentation generation.
* PATCH : REFACTOR : Upgraded hitchstory and strictyaml in hitch environment.


### 0.10.0

* MINOR : FEATURE : Optionally specify minimum_keys and maximum_keys in MapPattern.


### 0.9.0

* MINOR : FEATURE : Revalidation of code parsed with any (to make it work with scalar values).
* PATCH : REFACTOR : Renamed defer validation -> revalidation.
* MINOR : FEATURE : Revalidation of code parsed with Any.
* PATCH : REFACTOR : Added more useful YAMLChunk methods.
* PATCH : REFACTOR : Fixed type assertions.
* PATCH : FEATURE : Added assert for or validators.
* PATCH : FEATURE : Clearer error messages for non-matching scalars.
* PATCH : REFACTOR : Made linter happy.
* MINOR : FEATURE : Made clearer exception messages and prevented invalid validators from being used in compound validators.
* PATCH : REFACTOR : Reworked the way YAML objects are created.
* PATCH : REFACTOR : Reworked the way mapping, sequence, 'or' and scalar validators work.
* PATCH : REFACTOR : Add doctests to the regression suite.
* PATCH : REFACTOR : Clean up Map() class so it interacts only via chunk.process().
* PATCH : REFACTOR : Cleaned up some stories.
* PATCH : REFACTOR : Make linter happy.
* PATCH : REFACTOR : Moved more validation functionality into the chunk object.
* PATCH : REFACTOR : Clean up validator code.
* PATCH : REFACTOR : Move more core code away from validators into YAMLChunk.


### 0.8.0

* MINOR : FEATURE : Enum with item validators.
* MINOR : FEATURE : Mappings with key validators.
* MINOR : FEATURE : Key validation using Map().
* PATCH : PERFORMANCE IMPROVEMENTS : Avoided the use of deepcopy() every time a validator is used.
* MINOR BUGFIX : Roundtripping failure fixes.
* PATCH : REFACTOR : Only use chunk object in scalar validators.
* PATCH : REFACTOR : Removed dependency on two variables being fed in to the validate_scalar method.


### 0.7.3

* PERFORMANCE : Improved performance of dumping by restricting the number of times deepcopy() is called.
* FEATURE : Performance improvements.
* FEATURE : Create dumpable YAML documents from simple dicts/lists of python data.
* FEATURE : Create documents from scratch.
* FEATURE : Create YAML documents directly.
* FEATURE : Merging of YAML documents.
* BUGFIX : Handle roundtripping changing indexed elements in sequences.
* BUGFIX : Fix for scalar value roundtripping.
* FEATURE : Set sequences using lists.
* FEATURE : Use 'yes' and 'no' as default boolean values.
* FEATURE : Set nested mappings that get correctly validated using __setitem__ interface on YAML() objects.
* BUGFIX : Don't futz with the ordering of keys when setting vars via __setitem__.


### 0.7.2

* BUGFIX : Decimal point representer does not work with decimal.Decimal() object, so using float instead.
* BUGFIX : In python 2.x, the __ne__ magic method is called on != rather than negating the result of the __eq__ method. This caused undesired behavior in python 2.x.
* FEATURE : Parser errors will have the correct label attached.
* FEATURE : .data now returns ordereddicts.
* BUG : Boolean 'y' and 'n' values ought to resolve to True and False.
* BUG : Map keys were accidentally optional by default.
* BUG : Disallowed exceptions were previously not labeled.
* BUG : Duplicate key exceptions were previously not labeled.
* BUG : Fix for roundtripping multiline strings in python 2.
* FEATURE : Label parsed YAML and have the label appear in exceptions.
* BUG : Fix the way that data is roundtrip loaded into the yaml object via __setitem__.
* BUG : Fixed roundtripping without using load()


### 0.7.0

* FEATURE : Modified the way that roundtripping works.


### 0.6.2

* FEATURE : Added version number accessible from __init__.py
* BUG : Fixed the miscounting of list lines when getting start_line/end_line.


### 0.6.0

* BUG : Fixed import issues.
* FEATURE : Added email and url validators.
* FEATURE : Added Regex validator.


### 0.5.9


No relevant code changes.

### 0.5.8

* BUG : Fixed boolean error.


### 0.5.7

* BUG : Fixed MapPattern errors caused when editing items.


### 0.5.6

* FEATURE : Strict type checking when setting values.


### 0.5.5

* BUG : Fix roundtripping when using non-ascii characters.
* BUG : Fixed unicode roundtripping error.


### 0.5.4

* BUG : Fix mishandling of special characters in mappings.
* BUG : Handle invalid keys which are non-ascii characters gracefully
* BUG : Fix for character encoding issues that occur when non-string scalars see invalid input.


### 0.5.3

* BUG : Third fix for character encoding issues (#18: hat tip @jpscaletti)
* BUG : Second fix for character encoding issues (#18: hat tip Juan Pablo-Scaletti)
* BUG : Fix for #18 (hat tip Juan Pablo-Scaletti)


### 0.5.2

* BUG : Fix for #17 (hat tip @kshpytsya)


### 0.5.1

* FEATURE : YAML object importable directly from module.


### 0.5.0

* BUG : Fixed some broken elements of roundtripping.
* BUG : .data representations did not give keys as strings.
* BUG : Fixed bool(x) overriding in python 2.
* FEATURE : Greater than / less than implemented along with better post-representation assignment to mappings.
* FEATURE : Better repr()
* BUG : Keys are now represented as YAML() objects with full access to the location of the key in the YAML document.
* FEATURE : Added is_[scalar|mapping|sequence] methods.
* FEATURE : .values() on YAML object.
* FEATURE : Added .value property to YAML object.
* FEATURE : Implemented __contains__ so the 'in' method can be used.
* FEATURE : Added .get(val) and .keys() so mapping YAML objects can be treated like dicts.
* FEATURE : Added .items() to YAML object.
* FEATURE : Handle srting casting for integers.
* FEATURE : Raise TypeError when trying to cast a string to bool.
* FEATURE : Raise TypeError when attempting to cast YAML(bool) to string.
* FEATURE : Get lines for a specific YAML value, lines before it and lines after.
* FEATURE : Print line numbers of YAML elements.
* FEATURE : Any validator.
* FEATURE : Fixed length sequence validation.
* BUG : Fixed roundtripping.
* FEATURE : Rountripped YAML with modifications.
* BUG : Fixed ruamel.yaml version at a higher level.
* FEATURE : Parse YAML into roundtrippable YAML object.


### 0.4.2


No relevant code changes.

### 0.4.1

* BUG : Fixed comma separated validator - now removes trailing spaces when parsing "a, b, c" so it does not parse as "a", " b", " c".


### 0.4.0

* FEATURE: Comma separated values.


### 0.3.9

* FEATURE : Added import for CommentedYAML type.


### 0.3.8

* FEATURE : Empty property validation.


### 0.3.7

* BUG : Fixed ruamel.yaml importing so that it works with earlier versions too.


### 0.3.6

* BUG : Fixed 13.1 ruamel.yaml issue.


### 0.3.5

* BUG : Stray print statement.


### 0.3.3

* BUG : Disallow flow style was failing with sequences.


### 0.3.2


No relevant code changes.

### 0.3.1

* BUG : Fixed mis-parsing caused by 'null' and non-strings in dictionary keys.


### 0.3

* FEATURE : Datetime parsing.
* BUG : When loading a blank string using 'Any' it returned None by accident.


### 0.2

* FEATURE : YAMLValidationError now inherits from and uses the same mechanism as MarkedYAMLError.


### 0.1.6


No relevant code changes.

### 0.1.5

* FEATURE : Duplicate keys disallowed.


### 0.1.4

* FEATURE : Made the default to parse all scalars to string (Any validator) and added validator that returns CommentedSeq/CommentedMap.


### 0.1.3

* FEATURE : Clearer exception messages.
* BUG : Fixed bug in sequence validator.


### 0.1.2

* BUG : Single value YAML documents now allowed.
* BUG : Raise type error if it isn't a string passed through.

