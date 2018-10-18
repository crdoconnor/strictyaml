from strictyaml.exceptions import YAMLValidationError, YAMLSerializationError
from strictyaml.representation import YAML
import sys

if sys.version_info[0] == 3:
    unicode = str


class Validator(object):
    def __or__(self, other):
        return OrValidator(self, other)

    def __call__(self, chunk):
        self.validate(chunk)
        return YAML(chunk.strictparsed(), text=None, chunk=chunk, validator=self)

    def __repr__(self):
        return u"{0}()".format(self.__class__.__name__)


class OrValidator(Validator):
    def __init__(self, validator_a, validator_b):
        assert isinstance(validator_a, Validator), "validator_a must be a Validator"
        assert isinstance(validator_b, Validator), "validator_b must be a Validator"
        self._validator_a = validator_a
        self._validator_b = validator_b

    def to_yaml(self, value):
        try:
            return self._validator_a.to_yaml(value)
        except YAMLSerializationError:
            return self._validator_b.to_yaml(value)

    def __call__(self, chunk):
        try:
            result = self._validator_a(chunk)
            result._validator = self
            return result
        except YAMLValidationError as error:
            result = self._validator_b(chunk)
            result._validator = self
            return result

    def __repr__(self):
        return u"{0} | {1}".format(repr(self._validator_a), repr(self._validator_b))
