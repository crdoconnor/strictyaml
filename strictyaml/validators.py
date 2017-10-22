from strictyaml.exceptions import YAMLValidationError
from strictyaml.representation import YAML
import sys

if sys.version_info[0] == 3:
    unicode = str


class Validator(object):
    def __or__(self, other):
        return OrValidator(self, other)

    def __call__(self, chunk):
        return YAML(
            self.validate(chunk),
            text=chunk.contents if isinstance(chunk.contents, (unicode, str)) else None,
            chunk=chunk,
            validator=self
        )


class OrValidator(Validator):
    def __init__(self, validator_a, validator_b):
        self._validator_a = validator_a
        self._validator_b = validator_b

    def validate(self, chunk):
        try:
            return self._validator_a(chunk)
        except YAMLValidationError:
            return self._validator_b(chunk)

    def __repr__(self):
        return u"{0} | {1}".format(repr(self._validator_a), repr(self._validator_b))
