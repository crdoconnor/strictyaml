from ruamel.yaml.comments import CommentedSeq, CommentedMap
from ruamel.yaml import RoundTripDumper
from ruamel.yaml import dump
from copy import deepcopy


class YAML(object):
    def __init__(self, value, text=None, document=None, location=None):
        self._value = value
        self._text = str(value) if text is None else text
        self._document = deepcopy(document)
        self._location = location

    def __int__(self):
        return self._value

    def __str__(self):
        return str(self._value)

    @property
    def data(self):
        if type(self._value) is CommentedMap:
            return {key: value.data for key, value in self._value.items()}
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

            for key, value in new_commented_map.items():
                new_commented_map[key] = value.as_marked_up()
            return new_commented_map
        elif isinstance(self._value, CommentedSeq):
            new_commented_seq = deepcopy(self._value)

            for i, item in enumerate(new_commented_seq):
                new_commented_seq[i] = item.as_marked_up()
            return new_commented_seq
        else:
            return self._text

    @property
    def start_line(self):
        return self._location.start_line(self._document)

    @property
    def end_line(self):
        return self._location.end_line(self._document)

    def __float__(self):
        return float(self._value)

    def __repr__(self):
        return u"YAML({0})".format(self.data)

    def __bool__(self):
        if isinstance(self._value, bool):
            return self._value
        else:
            raise TypeError("not bool")

    def __getitem__(self, index):
        return self._value[index]

    def __setitem__(self, index, value):
        self._value[index] = YAML(value)

    def __hash__(self):
        return hash(self._value)

    def __len__(self):
        return len(self._value)

    def as_yaml(self):
        return dump(self.as_marked_up(), Dumper=RoundTripDumper)

    @property
    def text(self):
        if isinstance(self._value, CommentedMap):
            raise TypeError("{0} is a mapping, has no text value.".format(repr(self)))
        if isinstance(self._value, CommentedSeq):
            raise TypeError("{0} is a sequence, has no text value.".format(repr(self)))
        return str(self._text)

    def __eq__(self, value):
        return self.data == value
