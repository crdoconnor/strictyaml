from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.exceptions import raise_type_error
from ruamel.yaml import RoundTripDumper
from ruamel.yaml import dump
from strictyaml import utils
from copy import deepcopy
import decimal


class YAML(object):
    def __init__(self, value, text=None, document=None, location=None):
        self._value = value
        self._text = str(value) if text is None else text
        self._document = deepcopy(document)
        self._location = location

    def __int__(self):
        return int(self._value)

    def __str__(self):
        if type(self._value) in (str, int, float, decimal.Decimal):
            return str(self._value)
        elif isinstance(self._value, CommentedMap) or isinstance(self._value, CommentedSeq):
            raise TypeError(
                "Cannot cast mapping/sequence '{0}' to string".format(repr(self._value))
            )
        else:
            raise_type_error(
                repr(self), "str", "str(yamlobj.value) or str(yamlobj.text)"
            )

    @property
    def data(self):
        if type(self._value) is CommentedMap:
            mapping = {}
            for key, value in self._value.items():
                if type(key) is str:
                    mapping[key] = value.data
                else:
                    mapping[key.data] = value.data
            return mapping
        elif type(self._value) is CommentedSeq:
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
            if utils.is_integer(self._text):
                return int(self._text)
            elif utils.is_decimal(self._text):
                return decimal.Decimal(self._text)
            else:
                return self._text

    @property
    def start_line(self):
        """
        Return line number that the element starts on (including preceding comments).
        """
        return self._location.start_line(self._document)

    @property
    def end_line(self):
        """
        Return line number that the element ends on (including trailing comments).
        """
        return self._location.end_line(self._document)

    def lines(self):
        """
        Return a string of the lines which make up the selected line
        including preceding and trailing comments.
        """
        return self._location.lines(self._document)

    def lines_before(self, how_many):
        return self._location.lines_before(self._document, how_many)

    def lines_after(self, how_many):
        return self._location.lines_after(self._document, how_many)

    def __float__(self):
        return float(self._value)

    def __repr__(self):
        return u"YAML({0})".format(self.data)

    def __bool__(self):
        if isinstance(self._value, bool):
            return self._value
        else:
            raise_type_error(
                repr(self), "bool", "bool(yamlobj.value) or bool(yamlobj.text)"
            )

    def __nonzero__(self):
        return self.__bool__()

    def __getitem__(self, index):
        return self._value[index]

    def __setitem__(self, index, value):
        if isinstance(value, YAML):
            self._value[index] = value.copy()
        else:
            self._value[index] = YAML(value)

    def __delitem__(self, index):
        del self._value[index]

    def __hash__(self):
        return hash(self._value)

    def __len__(self):
        return len(self._value)

    def as_yaml(self):
        return dump(self.as_marked_up(), Dumper=RoundTripDumper)

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
    def text(self):
        if isinstance(self._value, CommentedMap):
            raise TypeError("{0} is a mapping, has no text value.".format(repr(self)))
        if isinstance(self._value, CommentedSeq):
            raise TypeError("{0} is a sequence, has no text value.".format(repr(self)))
        return self._text

    def copy(self):
        return deepcopy(self)

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

    def __eq__(self, value):
        return self.data == value
