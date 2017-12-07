from ruamel.yaml.comments import CommentedSeq, CommentedMap
from ruamel.yaml import dump, RoundTripDumper
from strictyaml.exceptions import YAMLValidationError
from strictyaml import utils
from copy import deepcopy
import sys

if sys.version_info[0] == 3:
    unicode = str


class YAMLChunk(object):
    """
    Represents a section of the document - everything from the whole document
    all the way to one scalar value.
    """
    def __init__(self, document, pointer=None, label=None, strictparsed=None):
        self._document = document
        self._pointer = pointer if pointer is not None \
            else YAMLPointer()
        self._label = label
        self._strictparsed = deepcopy(document) if strictparsed is None else strictparsed

    def expecting_but_found(self, expecting, found=None):
        raise YAMLValidationError(
            expecting,
            found if found is not None else "found {0}".format(self.found()),
            self
        )

    def while_parsing_found(self, what, found=None):
        self.expecting_but_found("while parsing {0}".format(what), found=found)

    def process(self, new_item):
        strictparsed = self.pointer.parent().get(self._strictparsed, strictdoc=True)

        if self.pointer.is_index():
            index = self.pointer._indices[-1][1]
            if hasattr(strictparsed, '_value'):
                strictparsed._value[index] = new_item
            else:
                strictparsed[index] = new_item
        elif self.pointer.is_key():
            key = self.pointer._indices[-1][1][0]
            if hasattr(strictparsed, '_value'):
                existing_val = strictparsed._value[key]
                del strictparsed._value[key]
                strictparsed._value[new_item] = existing_val
            else:
                existing_val = strictparsed[key]
                del strictparsed[key]
                strictparsed[new_item] = existing_val
        elif self.pointer.is_val():
            key = self.pointer._indices[-1][1][0]
            if hasattr(strictparsed, '_value'):
                strictparsed._value[key] = new_item
            else:
                strictparsed[key] = new_item

    def validate(self, schema):
        schema(self)

    def is_sequence(self):
        return isinstance(self.contents, CommentedSeq)

    def is_mapping(self):
        return isinstance(self.contents, CommentedMap)

    def is_scalar(self):
        return not isinstance(self.contents, (CommentedMap, CommentedSeq))

    def found(self):
        if self.is_sequence():
            return u"a sequence"
        elif self.is_mapping():
            return u"a mapping"
        elif self.contents == u'':
            return u"a blank string"
        elif utils.is_integer(self.contents):
            return u"an arbitrary integer"
        elif utils.is_decimal(self.contents):
            return u"an arbitrary number"
        else:
            return u"arbitrary text"

    def expect_sequence(self, expecting="when expecting a sequence"):
        if not self.is_sequence():
            self.expecting_but_found(expecting, "found {0}".format(self.found()))
        return [self.index(i) for i in range(len(self.contents))]

    def expect_mapping(self):
        if not self.is_mapping():
            self.expecting_but_found(
                "when expecting a mapping",
                "found {0}".format(self.found())
            )
        return [
            (
                self.key(regular_key, unicode(validated_key)),
                self.val(regular_key, unicode(validated_key)),
            )
            for (regular_key, validated_key) in
            zip(self.contents.keys(), self.strictparsed().keys())
        ]

    def expect_scalar(self, what):
        if not self.is_scalar():
            self.expecting_but_found(
                "when expecting {0}".format(what),
                "found {0}".format(self.found()),
            )

    @property
    def label(self):
        return self._label

    @property
    def document(self):
        return self._document

    @property
    def pointer(self):
        return self._pointer

    def fork(self):
        """
        Return a chunk to the same location in a duplicated document.

        Used when modifying a YAML chunk so that the modification can be validated
        before changing it.
        """
        return YAMLChunk(deepcopy(self._document), pointer=self.pointer, label=self.label)

    def make_child_of(self, chunk):
        """
        Used when inserting a chunk of YAML into another chunk.
        """
        if self.is_mapping():
            for key, value in self.contents.items():
                self.key(key, key).pointer.make_child_of(chunk.pointer)
                self.val(key, key).make_child_of(chunk)
        elif self.is_sequence():
            for index, item in enumerate(self.contents):
                self.index(index).make_child_of(chunk)
        else:
            self.pointer.make_child_of(chunk.pointer)

    def _select(self, pointer):
        return YAMLChunk(
            self._document,
            pointer=pointer,
            label=self._label,
            strictparsed=self._strictparsed
        )

    def index(self, index):
        """
        Return a chunk in a sequence referenced by index.
        """
        return self._select(self._pointer.index(index))

    def val(self, key, strictkey=None):
        """
        Return a chunk referencing a value in a mapping with the key 'key'.
        """
        return self._select(self._pointer.val(key, strictkey))

    def key(self, key, strictkey=None):
        """
        Return a chunk referencing a key in a mapping with the name 'key'.
        """
        return self._select(self._pointer.key(key, strictkey))

    def textslice(self, start, end):
        """
        Return a chunk referencing a slice of a scalar text value.
        """
        return self._select(self._pointer.textslice(start, end))

    def start_line(self):
        return self._pointer.start_line(self._document)

    def end_line(self):
        return self._pointer.end_line(self._document)

    def lines(self):
        return self._pointer.lines(self._document)

    def lines_before(self, how_many):
        return self._pointer.lines_before(self._document, how_many)

    def lines_after(self, how_many):
        return self._pointer.lines_after(self._document, how_many)

    @property
    def contents(self):
        return self._pointer.get(self._document)

    def contentcopy(self):
        return deepcopy(self._pointer.get(self._document))

    def strictparsed(self):
        return self._pointer.get(self._strictparsed, strictdoc=True)


class YAMLPointer(object):
    """
    Represents a pointer to a specific location in a document.

    The pointer is a list of values (key lookups on mappings), indexes (index lookup
    on sequences) and keys (lookup for a particular key name in a mapping).
    """
    def __init__(self):
        self._indices = []

    def val(self, regularkey, strictkey):
        assert isinstance(regularkey, (str, unicode)), type(regularkey)
        assert isinstance(strictkey, (str, unicode)), type(strictkey)
        new_location = deepcopy(self)
        new_location._indices.append(('val', (regularkey, strictkey)))
        return new_location

    def is_val(self):
        return self._indices[-1][0] == 'val'

    def key(self, regularkey, strictkey):
        assert isinstance(regularkey, (str, unicode)), type(regularkey)
        assert isinstance(strictkey, (str, unicode)), type(strictkey)
        new_location = deepcopy(self)
        new_location._indices.append(('key', (regularkey, strictkey)))
        return new_location

    def is_key(self):
        return self._indices[-1][0] == 'key'

    def index(self, index):
        new_location = deepcopy(self)
        new_location._indices.append(('index', index))
        return new_location

    def is_index(self):
        return self._indices[-1][0] == 'index'

    def textslice(self, start, end):
        new_location = deepcopy(self)
        new_location._indices.append(('textslice', (start, end)))
        return new_location

    def is_textslice(self):
        return self._indices[-1][0] == 'textslice'

    def parent(self):
        new_location = deepcopy(self)
        new_location._indices = new_location._indices[:-1]
        return new_location

    def make_child_of(self, pointer):
        new_indices = deepcopy(pointer._indices)
        new_indices.extend(self._indices)

    def _slice_segment(self, indices, segment, include_selected):
        slicedpart = deepcopy(segment)

        if len(indices) == 0 and not include_selected:
            slicedpart = None
        else:
            if len(indices) > 0:
                if indices[0][0] in ("val", "key"):
                    index = indices[0][1][0]
                else:
                    index = indices[0][1]
                start_popping = False

                if isinstance(segment, CommentedMap):
                    for key in segment.keys():
                        if start_popping:
                            slicedpart.pop(key)

                        if index == key:
                            start_popping = True

                            if isinstance(segment[index], (CommentedSeq, CommentedMap)):
                                slicedpart[index] = self._slice_segment(
                                    indices[1:],
                                    segment[index],
                                    include_selected=include_selected
                                )

                            if not include_selected and len(indices) == 1:
                                slicedpart.pop(key)

                if isinstance(segment, CommentedSeq):
                    for i, value in enumerate(segment):
                        if start_popping:
                            del slicedpart[-1]

                        if i == index:
                            start_popping = True

                            if isinstance(segment[index], (CommentedSeq, CommentedMap)):
                                slicedpart[index] = self._slice_segment(
                                    indices[1:],
                                    segment[index],
                                    include_selected=include_selected
                                )

                            if not include_selected and len(indices) == 1:
                                slicedpart.pop(index)

        return slicedpart

    def start_line(self, document):
        slicedpart = self._slice_segment(self._indices, document, include_selected=False)

        if slicedpart is None or slicedpart == {} or slicedpart == []:
            return 1
        else:
            return len(dump(slicedpart, Dumper=RoundTripDumper).rstrip().split('\n')) + 1

    def end_line(self, document):
        slicedpart = self._slice_segment(self._indices, document, include_selected=True)
        return len(dump(slicedpart, Dumper=RoundTripDumper).rstrip().split('\n'))

    def lines(self, document):
        return "\n".join(dump(document, Dumper=RoundTripDumper).split('\n')[
            self.start_line(document) - 1:self.end_line(document)
        ])

    def lines_before(self, document, how_many):
        return "\n".join(dump(document, Dumper=RoundTripDumper).split('\n')[
            self.start_line(document) - 1 - how_many:self.start_line(document) - 1
        ])

    def lines_after(self, document, how_many):
        return "\n".join(dump(document, Dumper=RoundTripDumper).split('\n')[
            self.end_line(document):self.end_line(document) + how_many
        ])

    def get(self, document, strictdoc=False):
        segment = document
        for index_type, index in self._indices:
            if index_type == "val":
                segment = segment[index[1] if strictdoc else index[0]]
            elif index_type == "index":
                segment = segment[index]
            elif index_type == "textslice":
                segment = segment[index[0]:index[1]]
            elif index_type == "key":
                segment = index[0] if strictdoc else index[1]
            else:
                raise RuntimeError("Invalid state")
        return segment

    def __repr__(self):
        return "<YAMLPointer: {0}>".format(self._indices)
