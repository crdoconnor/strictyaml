# Command-line interface
StrictYAML comes with a command-line tool, `strictyaml`, which can be used to
lint YAML files in a similar manner to [`yamllint`][yamllint].

Running `strictyaml` will print any errors encountered and an appropriate
summary at the end of execution, and set the exit code to `1` if any errors
were encountered.

Example output:

    $ strictyaml --no-symbols site.yml roles/common/tasks/xcode.yml
    While scanning
      in "site.yml", line 5, column 9:
          flow: { flow: val }
                ^ (line: 5)
    Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
      in "site.yml", line 5, column 10:
          flow: { flow: val }
                 ^ (line: 5)
    site.yml contained errors
    roles/common/tasks/xcode.yml validated successfully
    Encountered 1 error

    $ cat roles/common/tasks/xcode.yml | strictyaml -
    ☑ <stdin>
    All files validated successfully

    $ strictyaml --help
    usage: strictyaml [-h] [--version] [--color {never,auto,always}]
                      [--no-symbols]
                      file [file ...]

    Attempts to parse input files as StrictYAML, printing any parse errors.

    positional arguments:
      file                  File(s) to read input from. Use - for standard input.

    optional arguments:
      -h, --help            show this help message and exit
      --version             show program's version number and exit
      --color {never,auto,always}
                            Enable/disable colored terminal output
      --no-symbols          Print Unicode symbols in output

[yamllint]: https://github.com/adrienverge/yamllint
