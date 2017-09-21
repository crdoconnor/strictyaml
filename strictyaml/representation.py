from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.exceptions import raise_type_error
from strictyaml.yamllocation import YAMLChunk
from strictyaml.dumper import StrictYAMLDumper
from ruamel.yaml import dump
from copy import copy, deepcopy
from collections import OrderedDict
import decimal
import sys


if sys.version_info[0] == 3:
    unicode = str


def marked_up(data):
    if isinstance(data, dict):
        return CommentedMap([
            (marked_up(key), marked_up(value))
            for key, value in data.items()
        ])
    elif isinstance(data, list):
        return CommentedSeq([
            marked_up(item) for item in data
        ])
    elif isinstance(data, bool):
        return u"yes" if data else u"no"
    else:
        return data


class YAML(object):
    def __init__(self, value, text=None, chunk=None, validator=None):
        if isinstance(value, YAML):
            self._value = value._value
            self._text = value._text
            self._chunk = value._chunk
            self._validator = value._validator
            return

        self._validator = validator
        self._value = value
        if not isinstance(value, CommentedMap) and not isinstance(value, CommentedSeq):
            self._text = unicode(value) if text is None else text
        else:
            self._text = None
        self._chunk = YAMLChunk(text) if chunk is None else chunk

    def __int__(self):
        return int(self._value)

    def __str__(self):
        if type(self._value) in (unicode, int, float, decimal.Decimal):
            return unicode(self._value)
        elif isinstance(self._value, CommentedMap) or isinstance(self._value, CommentedSeq):
            raise TypeError(
                "Cannot cast mapping/sequence '{0}' to string".format(repr(self._value))
            )
        else:
            raise_type_error(
                repr(self), "str", "str(yamlobj.data) or str(yamlobj.text)"
            )

    def __unicode__(self):
        return self.__str__()

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
                if type(key) in (str, unicode):
                    mapping[key] = value.data
                else:
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
        if isinstance(self._value, CommentedMap):
            new_commented_map = deepcopy(self._value)

            for key, value in self._value.items():
                del new_commented_map[key._value]
                new_commented_map[key._value] = value.as_marked_up()
            return new_commented_map
        elif isinstance(self._value, CommentedSeq):
            new_commented_seq = deepcopy(self._value)

            for i, item in enumerate(self._value):
                new_commented_seq[i] = item.as_marked_up()
            return new_commented_seq
        else:
            from ruamel.yaml.scalarstring import ScalarString, PreservedScalarString
            if u"\n" in self._text:
                return PreservedScalarString(self._text)
            else:
                return ScalarString(self._text)

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

    def __nonzero__(self):
        return self.__bool__()

    def __getitem__(self, index):
        return self._value[index]

    def __setitem__(self, index, value):
        existing_value = self._value[index]
        new_value = existing_value.validator(YAMLChunk(marked_up(value)))

        # First validate against updated forked document
        proposed_chunk = self._chunk.fork()
        proposed_chunk.update(index, new_value)
        existing_value.validator(proposed_chunk.val(index))

        # If validation succeeds, update for real
        self._chunk.update(index, new_value)

        if new_value.is_mapping():
            for key, value in new_value.items():
                key._chunk._pointer = key._chunk._pointer.as_child_of(self._chunk.pointer)
                value._chunk._pointer = value._chunk._pointer.as_child_of(self._chunk.pointer)
        elif new_value.is_sequence():
            for item in new_value:
                item._chunk._pointer = item._chunk._pointer.as_child_of(self._chunk.pointer)
        else:
            new_value._chunk._pointer = new_value._chunk._pointer.as_child_of(self._chunk.pointer)

        self._value[YAML(index) if self.is_mapping() else index] = YAML(
            value=new_value,
            chunk=self._chunk.val(index) if self.is_mapping() else self._chunk.index(index),
            validator=existing_value.validator,
        )

    def __delitem__(self, index):
        del self._value[index]

    def __hash__(self):
        return hash(self._value)

    def __len__(self):
        return len(self._value)

    def as_yaml(self):
        """
        Render the YAML node and subnodes as string.
        """
        dumped = dump(self.as_marked_up(), Dumper=StrictYAMLDumper, allow_unicode=True)
        return dumped if sys.version_info[0] == 3 else dumped.decode('utf8')

    def items(self):
        if not isinstance(self._value, CommentedMap):
            raise TypeError("{0} not a mapping, cannot use .items()".format(repr(self)))
        return [(key, self._value[key]) for key, value in self._value.items()]

    def keys(self):
        if not isinstance(self._value, CommentedMap):
            raise TypeError("{0} not a mapping, cannot use .keys()".format(repr(self)))
        return [key for key, value in self._value.items()]

    def values(self):
        if not isinstance(self._value, CommentedMap):
            raise TypeError("{0} not a mapping, cannot use .values()".format(repr(self)))
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
        if isinstance(self._value, CommentedMap) or isinstance(self._value, CommentedSeq):
            raise TypeError("{0} not an orderable type.".format(repr(self._value)))
        return self._value > val

    def __lt__(self, val):
        if isinstance(self._value, CommentedMap) or isinstance(self._value, CommentedSeq):
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
        return not isinstance(self._value, CommentedSeq) \
            and not isinstance(self._value, CommentedMap)

    def document(self):
        return self._chunk.document

    def __eq__(self, value):
        return self.data == value

    def __ne__(self, value):
        return self.data != value
