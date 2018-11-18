from ruamel.yaml.comments import CommentedSeq, CommentedMap
from ruamel.yaml.scalarstring import PreservedScalarString
from strictyaml.exceptions import raise_type_error
from strictyaml.yamllocation import YAMLChunk
from strictyaml.dumper import StrictYAMLDumper
from ruamel.yaml import dump
from collections import OrderedDict
from copy import copy
import decimal
import sys


if sys.version_info[0] == 3:
    unicode = str


class YAMLIterator(object):
    def __init__(self, yaml_object):
        self._yaml_object = yaml_object
        self._index = 0

    def __iter__(self):
        return self

    def next(self):
        return self.__next__()

    def __next__(self):
        if self._index >= len(self._yaml_object):
            raise StopIteration
        else:
            self._index = self._index + 1
            return self._yaml_object[self._index - 1]


class YAML(object):
    """
    A YAML object represents a block of YAML which can be:

    * Used to extract parsed data from the YAML (.data).
    * Used to render to a string of YAML, with comments (.as_yaml()).
    * Revalidated with a stricter schema (.revalidate(schema)).
    """

    def __init__(self, value, validator=None):
        if isinstance(value, YAMLChunk):
            self._chunk = value
            self._validator = validator
            if value.is_scalar():
                self._value = validator.validate(value)
                if isinstance(self._value, YAML):
                    self._value = self._value._value
                self._text = value.contents
            else:
                self._value = (
                    value.strictparsed()._value
                    if isinstance(value.strictparsed(), YAML)
                    else value.strictparsed()
                )
                self._text = None
        elif isinstance(value, YAML):
            self._chunk = value._chunk
            self._validator = validator if validator is not None else value.validator
            self._value = value._value
            self._text = value._text
        else:
            self._chunk = YAMLChunk(value)
            self._validator = validator
            self._value = value
            self._text = unicode(value)
        self._selected_validator = None
        assert not isinstance(self._value, YAML)

    def __int__(self):
        # TODO: Raise more sensible exception if not int
        return int(self._value)

    def __str__(self):
        if not self.is_scalar():
            raise TypeError(
                "Cannot cast mapping/sequence '{0}' to string".format(repr(self._value))
            )
        elif type(self._value) in (unicode, str, int, float, decimal.Decimal):
            return unicode(self._value)
        else:
            raise_type_error(
                repr(self), "str", "str(yamlobj.data) or str(yamlobj.text)"
            )

    def __unicode__(self):
        return self.__str__()

    def revalidate(self, schema):
        if self.is_scalar():
            self._value = schema(self._chunk)._value
        else:
            result = schema(self._chunk)
            self._selected_validator = result._selected_validator
        self._validator = schema

    @property
    def data(self):
        """
        Returns raw data representation of the document or document segment.

        Mappings are rendered as ordered dicts, sequences as lists and scalar values
        as whatever the validator returns (int, string, etc.).

        If no validators are used, scalar values are always returned as strings.
        """
        if isinstance(self._value, CommentedMap):
            mapping = OrderedDict()
            for key, value in self._value.items():
                mapping[key.data] = value.data
            return mapping
        elif isinstance(self._value, CommentedSeq):
            return [item.data for item in self._value]
        else:
            return self._value

    def as_marked_up(self):
        """
        Returns ruamel.yaml CommentedSeq/CommentedMap objects
        with comments. This can be fed directly into a ruamel.yaml
        dumper.
        """
        return self._chunk.contents

    @property
    def start_line(self):
        """
        Return line number that the element starts on (including preceding comments).
        """
        return self._chunk.start_line()

    @property
    def end_line(self):
        """
        Return line number that the element ends on (including trailing comments).
        """
        return self._chunk.end_line()

    def lines(self):
        """
        Return a string of the lines which make up the selected line
        including preceding and trailing comments.
        """
        return self._chunk.lines()

    def lines_before(self, how_many):
        return self._chunk.lines_before(how_many)

    def lines_after(self, how_many):
        return self._chunk.lines_after(how_many)

    def __float__(self):
        return float(self._value)

    def __repr__(self):
        return u"YAML({0})".format(self.data)

    def __bool__(self):
        if isinstance(self._value, bool):
            return self._value
        else:
            raise_type_error(
                repr(self), "bool", "bool(yamlobj.data) or bool(yamlobj.text)"
            )

    def _strictindex(self, index):
        if isinstance(index, YAML):
            index = index.data
        if self.is_mapping():
            key_validator = (
                self._selected_validator.key_validator
                if self._selected_validator is not None
                else self._validator.key_validator
            )
            return key_validator(YAMLChunk(index)).data
        else:
            return index

    def __nonzero__(self):
        return self.__bool__()

    def __getitem__(self, index):
        return self._value[self._strictindex(index)]

    def __setitem__(self, index, value):
        strictindex = self._strictindex(index)
        try:
            value_validator = self._value[strictindex].validator
        except KeyError:
            # TODO: What if value isn't a YAML object?
            value_validator = value.validator

        new_value = (
            value_validator(value._chunk)
            if isinstance(value, YAML)
            else value_validator(YAMLChunk(value_validator.to_yaml(value)))
        )

        # Fork the value
        forked_chunk = self._chunk.fork(strictindex, new_value)

        # Validate and attach to current structure
        if self.is_mapping():
            updated_value = value_validator(forked_chunk.val(strictindex))
            updated_value._chunk.make_child_of(self._chunk.val(strictindex))
        else:
            updated_value = value_validator(forked_chunk.index(strictindex))
            updated_value._chunk.make_child_of(self._chunk.index(strictindex))

        marked_up = new_value.as_marked_up()

        # So that the nicer x: | style of text is used instead of
        # x: "text\nacross\nlines"
        if isinstance(marked_up, (str, unicode)):
            if u"\n" in marked_up:
                marked_up = PreservedScalarString(marked_up)

        self._chunk.contents[self._chunk.ruamelindex(strictindex)] = marked_up
        self._value[
            YAML(forked_chunk.ruamelindex(strictindex))
            if self.is_mapping()
            else forked_chunk.ruamelindex(strictindex)
        ] = new_value

    def __delitem__(self, index):
        strictindex = self._strictindex(index)
        del self._value[strictindex]
        del self._chunk.contents[self._chunk.ruamelindex(strictindex)]

    def __hash__(self):
        return hash(self._value)

    def __len__(self):
        return len(self._value)

    def as_yaml(self):
        """
        Render the YAML node and subnodes as string.
        """
        dumped = dump(self.as_marked_up(), Dumper=StrictYAMLDumper, allow_unicode=True)
        return dumped if sys.version_info[0] == 3 else dumped.decode("utf8")

    def items(self):
        if not isinstance(self._value, CommentedMap):
            raise TypeError("{0} not a mapping, cannot use .items()".format(repr(self)))
        return [(key, self._value[key]) for key, value in self._value.items()]

    def keys(self):
        if not isinstance(self._value, CommentedMap):
            raise TypeError("{0} not a mapping, cannot use .keys()".format(repr(self)))
        return [key for key, _ in self._value.items()]

    def values(self):
        if not isinstance(self._value, CommentedMap):
            raise TypeError(
                "{0} not a mapping, cannot use .values()".format(repr(self))
            )
        return [self._value[key] for key, value in self._value.items()]

    def get(self, index, default=None):
        if not isinstance(self._value, CommentedMap):
            raise TypeError("{0} not a mapping, cannot use .get()".format(repr(self)))
        return self._value[index] if index in self._value.keys() else default

    def __contains__(self, item):
        if isinstance(self._value, CommentedSeq):
            return item in self._value
        elif isinstance(self._value, CommentedMap):
            return item in self.keys()
        else:
            return item in self._value

    def __iter__(self):
        if self.is_sequence():
            return YAMLIterator(self)
        elif self.is_mapping():
            return YAMLIterator(self.keys())
        else:
            raise TypeError("{0} is a scalar value, cannot iterate.".format(repr(self)))

    @property
    def validator(self):
        return self._validator

    @property
    def text(self):
        """
        Return string value of scalar, whatever value it was parsed as.
        """
        if isinstance(self._value, CommentedMap):
            raise TypeError("{0} is a mapping, has no text value.".format(repr(self)))
        if isinstance(self._value, CommentedSeq):
            raise TypeError("{0} is a sequence, has no text value.".format(repr(self)))
        return self._text

    def copy(self):
        return copy(self)

    def __gt__(self, val):
        if isinstance(self._value, CommentedMap) or isinstance(
            self._value, CommentedSeq
        ):
            raise TypeError("{0} not an orderable type.".format(repr(self._value)))
        return self._value > val

    def __lt__(self, val):
        if isinstance(self._value, CommentedMap) or isinstance(
            self._value, CommentedSeq
        ):
            raise TypeError("{0} not an orderable type.".format(repr(self._value)))
        return self._value < val

    @property
    def value(self):
        return self._value

    def is_mapping(self):
        return isinstance(self._value, CommentedMap)

    def is_sequence(self):
        return isinstance(self._value, CommentedSeq)

    def is_scalar(self):
        return not isinstance(self._value, CommentedSeq) and not isinstance(
            self._value, CommentedMap
        )

    @property
    def scalar(self):
        if isinstance(self._value, (CommentedMap, CommentedSeq)):
            raise TypeError("{0} has no scalar value.".format(repr(self)))
        return self._value

    def whole_document(self):
        return self._chunk.whole_document

    def __eq__(self, value):
        return self.data == value

    def __ne__(self, value):
        return self.data != value
