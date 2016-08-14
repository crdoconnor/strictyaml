from ruamel.yaml.comments import CommentedSeq, CommentedMap
from strictyaml.exceptions import YAMLValidationError
from strictyaml.yamllocation import YAMLLocation
import decimal
import copy
import re


class Optional(object):
    def __init__(self, key):
        self.key = key


class Validator(object):
    def __or__(self, other):
        return OrValidator(self, other)

    def __call__(self, document, location=None):
        if location is None:
            location = YAMLLocation()
        return self.validate(document, location)


class OrValidator(Validator):
    def __init__(self, validator_a, validator_b):
        self._validator_a = validator_a
        self._validator_b = validator_b

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)

        error1 = None
        error2 = None

        try:
            validation_a = self._validator_a(document, location=location)
        except YAMLValidationError as err:
            error1 = err

        try:
            validation_b = self._validator_b(document, location=location)
        except YAMLValidationError as err:
            error2 = err

        if error1 is None:
            return validation_a
        if error2 is None:
            return validation_b

        if error1 is not None:
            raise error1
        if error2 is not None:
            raise error2


class Any(Validator):
    def validate(self, document, location=None):
        return location.get(document)


class Scalar(Validator):
    @property
    def rule_description(self):
        return "a {0}".format(self.__class__.__name__.lower())

    def validate(self, document, location=None):
        val = location.get(document)

        if type(val) == CommentedSeq or type(val) == CommentedMap:
            raise YAMLValidationError(
                "Not {0}".format(self.rule_description),
                document,
                location=location
            )
        else:
            return self.validate_scalar(document, location=location)


class Enum(Scalar):
    def __init__(self, restricted_to):
        # TODO: Validate set or list
        # TODO: Validate enum is always string
        self._restricted_to = restricted_to

    def validate(self, document, location=None):
        val = str(location.get(document))
        if val not in self._restricted_to:
            raise YAMLValidationError(
                "{} not in enum".format(val),
                document,
                location=location
            )
        else:
            return val


class Str(Scalar):
    def validate_scalar(self, document, location):
        return str(location.get(document))


class Int(Scalar):
    def validate_scalar(self, document, location):
        val = str(location.get(document))
        if re.compile("^[-+]?\d+$").match(val) is None:
            raise YAMLValidationError("not an integer", document, location)
        else:
            return int(val)


class Bool(Scalar):
    def validate_scalar(self, document, location):
        val = str(location.get(document))
        if str(val).lower() not in ["yes", "true", "no", "false", "on", "off", "1", "0", ]:
            raise YAMLValidationError("not a bool", document, location)
        else:
            if val in ["yes", "true", "on", "1", ]:
                return True
            else:
                return False


class Float(Scalar):
    def validate_scalar(self, document, location):
        val = str(location.get(document))
        if re.compile(r"^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$").match(str(val)) is None:
            raise YAMLValidationError("not a float", document, location)
        else:
            return float(val)


class Decimal(Scalar):
    def validate_scalar(self, document, location):
        val = str(location.get(document))
        if re.compile(r"^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$").match(str(val)) is None:
            raise YAMLValidationError("not a decimal", document, location)
        else:
            return decimal.Decimal(val)


class MapPattern(Validator):
    def __init__(self, key_validator, value_validator):
        self._key_validator = key_validator
        self._value_validator = value_validator

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = {}

        if type(location.get(document)) != CommentedMap:
            raise YAMLValidationError("Not a mapping", document)
        else:
            for key, value in location.get(document).items():
                valid_key = self._key_validator(document, location.key(key))
                valid_val = self._value_validator(document, location.val(key))
                return_snippet[valid_key] = valid_val

        return return_snippet


class Map(Validator):
    def __init__(self, validator, location=None):
        self._validator = validator

        self._validator_dict = {
            key.key if type(key) == Optional else key: value for key, value in validator.items()
        }

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = {}

        if type(location.get(document)) != CommentedMap:
            raise YAMLValidationError("Not a map", document, location=location)
        else:
            for key, value in location.get(document).items():
                if key not in self._validator_dict.keys():
                    raise YAMLValidationError(
                        "Invalid key found {}".format(key), document, location=location.key(key)
                    )

                return_snippet[key] = self._validator_dict[key](
                    document, location=location.val(key)
                )

        return return_snippet


class Seq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)
        return_snippet = []

        if type(location.get(document)) != CommentedSeq:
            raise YAMLValidationError("Not a sequence", document, location=location)
        else:
            for i, item in enumerate(location.get(document)):
                return_snippet.append(self._validator(document, location=location.index(i)))

        return return_snippet


class UniqueSeq(Validator):
    def __init__(self, validator):
        self._validator = validator

    def validate(self, document, location=None):
        if location is None:
            location = YAMLLocation()
            document = copy.deepcopy(document)

        return_snippet = []

        if type(location.get(document)) != CommentedSeq:
            raise YAMLValidationError("Not a sequence", document, location=location)
        else:
            existing_items = set()

            for i, item in enumerate(location.get(document)):
                if item in existing_items:
                    raise YAMLValidationError("Duplicates found", document, location=location)
                else:
                    existing_items.add(item)
                    return_snippet.append(self._validator(document, location=location.index(i)))

        return return_snippet
