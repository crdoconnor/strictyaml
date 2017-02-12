from ruamel.yaml.comments import CommentedSeq, CommentedMap
from ruamel.yaml import dump, RoundTripDumper
from copy import deepcopy


class YAMLLocation(object):
    def __init__(self):
        self._indices = []

    def val(self, index):
        new_location = deepcopy(self)
        new_location._indices.append(('val', index))
        return new_location

    def key(self, name):
        new_location = deepcopy(self)
        new_location._indices.append(('key', name))
        return new_location

    def index(self, index):
        new_location = deepcopy(self)
        new_location._indices.append(('index', index))
        return new_location

    def _slice_segment(self, indices, segment, include_selected):
        slicedpart = deepcopy(segment)

        if len(indices) == 0 and not include_selected:
            slicedpart = None
        else:
            if len(indices) > 0:
                index = indices[0][1]
                start_popping = False

                if type(segment) == CommentedMap:
                    for key in segment.keys():
                        if start_popping:
                            slicedpart.pop(key)

                        if index == key:
                            start_popping = True

                            if type(segment[index]) in (CommentedSeq, CommentedMap, ):
                                slicedpart[index] = self._slice_segment(
                                    indices[1:],
                                    segment[index],
                                    include_selected=include_selected
                                )

                            if not include_selected and len(indices) == 1:
                                slicedpart.pop(key)

                if type(segment) == CommentedSeq:
                    for i, value in enumerate(segment):
                        if start_popping:
                            slicedpart.pop(0)

                        if i == index:
                            start_popping = True

                            if type(segment[index]) in (CommentedSeq, CommentedMap, ):
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

    def get(self, document):
        segment = deepcopy(document)
        for index_type, index in self._indices:
            if index_type == "val":
                segment = segment[index]
            elif index_type == "index":
                segment = segment[index]
            else:
                segment = index
        return segment

    def __repr__(self):
        return "<YAMLLocation: {0}>".format(self._indices)
