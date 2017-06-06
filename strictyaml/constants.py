TRUE_VALUES = ["yes", "true", "on", "1", ]

FALSE_VALUES = ["no", "false", "off", "0", ]

BOOL_VALUES = TRUE_VALUES + FALSE_VALUES

REGEXES = {
    "email": r".+?\@.+?",
    "url": (
        r"(ht|f)tp(s?)\:\/\/[0-9a-zA-Z]([-.\w]*[0-9a-zA-Z])*"
        r"(:(0-9)*)*(\/?)([a-zA-Z0-9\-\.\?\,\'\/\\\+&amp;%\$#_]*)?"
    ),
}
