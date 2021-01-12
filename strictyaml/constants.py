TRUE_VALUES = ["yes", "true", "on", "1", "y"]

FALSE_VALUES = ["no", "false", "off", "0", "n"]

BOOL_VALUES = TRUE_VALUES + FALSE_VALUES

REGEXES = {
    "email": r".+?\@.+?",

    # https://urlregex.com/
    "url": r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+",
}
