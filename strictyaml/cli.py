import argparse
import sys

import colorama
from termcolor import cprint

from strictyaml import load, YAMLError, __version__


def argparser():
    parser = argparse.ArgumentParser(
        description='''Attempts to parse input files as StrictYAML,
        printing any parse errors.''')
    parser.add_argument(
        '--version', action='version',
        version='%(prog)s ' + __version__ + ' MIT License')
    parser.add_argument(
        '--color', choices=['never', 'auto', 'always'],
        default='auto', help='Enable/disable colored terminal output')
    parser.add_argument(
        '--no-symbols', action='store_false', dest='symbols',
        help='''Print Unicode symbols in output''')
    parser.add_argument(
        'file', nargs='*', type=argparse.FileType('r', encoding='utf-8'),
        help='''File(s) to read input from.''')
    return parser


def set_colors(state):
    """
    Initializes terminal colored output; 'state' may be 'never', 'auto', or
    'always'
    """
    if state == 'never':
        colorama.init(strip=True)
    elif state == 'always':
        colorama.init(strip=False)
    elif state == 'auto':
        colorama.init()


def parsed(fname, success, symbols=True):
    """
    A message to print after parsing a file, dependent on the file's name, if
    parsing succeeded, and if we can use symbols in the message; returns a
    (message, color) tuple.
    """
    if success:
        color = 'green'
        if symbols:
            txt = '☑ ' + fname
        else:
            txt = fname + ' validated successfully'
    else:
        color = 'red'
        if symbols:
            txt = '☒ ' + fname
        else:
            txt = fname + ' contained errors'
    return txt, color


def exit(errors, symbols=True):
    """
    Prints a summary message and exits with the proper code.
    'errors' is an integer.
    """
    if errors > 0:
        exit_code = 1
        msg = 'Encountered ' + str(errors) + ' error'
        if errors > 1:
            # pluralize 'errors'
            msg += 's'
        color = 'red'
    else:
        exit_code = 0
        msg = 'All files validated successfully'
        color = 'green'

    cprint(msg, color)
    sys.exit(exit_code)


def main(args=None):
    if args is None:
        args = sys.argv[1:]
    parser = argparser()
    args = parser.parse_args(args)
    set_colors(args.color)
    if not args.file:
        if sys.stdin.isatty():
            parser.print_help()
            sys.exit(1)
        else:
            args.file = [sys.stdin]
    errors = 0

    for f in args.file:
        success = True
        with f as file_:
            content = file_.read()
            try:
                load(content, label=file_.name)
            except YAMLError as error:
                errors += 1
                success = False
                print(error)
            msg, color = parsed(file_.name, success, symbols=args.symbols)
            cprint(msg, color)

    exit(errors, args.symbols)


if __name__ == '__main__':
    main()
