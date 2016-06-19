class YAMLValidationError(Exception):
    def __init__(self, message, document, location):
        self._message = message
        self._document = document
        self._location = location

    @property
    def start_line(self):
        return self._location.start_line(self._document)

    @property
    def end_line(self):
        return self._location.end_line(self._document)

    @property
    def message(self):
        return self._message
