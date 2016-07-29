from strictyaml.yamllocation import YAMLLocation
from ruamel.yaml import YAMLError

class StrictYAMLError(YAMLError):
    @property
    def start_line(self):
        return self._start_line

    @property
    def end_line(self):
        return self._end_line

    @property
    def message(self):
        return self._message


class YAMLValidationError(StrictYAMLError):
    def __init__(self, message, document, location):
        self._message = message
        self._document = document
        self._start_line = location.start_line(self._document)
        self._end_line = location.end_line(self._document)


class DisallowedToken(StrictYAMLError):
    MESSAGE = "Disallowed token"

    def __init__(self, document, start_line, end_line):
        self._document = document
        self._start_line = start_line
        self._end_line = end_line
        self._message = self.MESSAGE


class TagTokenDisallowed(DisallowedToken):
    MESSAGE = "Tag tokens not allowed"


class FlowMappingDisallowed(DisallowedToken):
    MESSAGE = "Flow mapping tokens not allowed"


class AnchorTokenDisallowed(DisallowedToken):
    MESSAGE = "Anchor tokens not allowed"