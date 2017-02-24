from re import compile


def is_integer(value):
    return compile("^[-+]?\d+$").match(value) is not None


def is_decimal(value):
    return compile(r"^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$").match(value) is not None
