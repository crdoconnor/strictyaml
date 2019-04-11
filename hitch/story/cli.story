strictyaml cli:
    docs: cli
    experimental: yes
    based on: strictyaml
    about: |
        The strictyaml command-line tool allows simple validation of YAML
        files, and can be useful in CI tools or as a linter.
    description: |
        strictyaml can read input from stdin.
        Note that strictyaml will only report at most one error per input file.
        Note that if stdin is not a tty and no filename arguments are given,
        strictyaml will read from stdin.

    steps:
        - Shell:
            command: strictyaml hitch/test_data/flow.yml
            stdout: |
                While scanning
                  in "hitch/test_data/flow.yml", line 1, column 7:
                    flow: { key: val }
                          ^ (line: 1)
                Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
                  in "hitch/test_data/flow.yml", line 1, column 8:
                    flow: { key: val }
                           ^ (line: 1)
                ☒ hitch/test_data/flow.yml
                Encountered 1 error
            rc: 1
        - Shell:
            command: strictyaml hitch/story/cli.story
            rc: 0
            stdout: |
                ☑ hitch/story/cli.story
                All files validated successfully
        - Shell:
            command: strictyaml --no-symbols hitch/story/cli.story
            rc: 0
            stdout: |
                hitch/story/cli.story validated successfully
                All files validated successfully
        - Shell:
            command: strictyaml hitch/test_data/duplicate_keys.yml
            rc: 1
            stdout: |
                While parsing
                  in "hitch/test_data/duplicate_keys.yml", line 2, column 1:
                    x: 2
                    ^ (line: 2)
                Duplicate key 'x' found
                  in "hitch/test_data/duplicate_keys.yml", line 2, column 2:
                    x: 2
                     ^ (line: 2)
                ☒ hitch/test_data/duplicate_keys.yml
                Encountered 1 error
        - Shell:
            command: strictyaml hitch/test_data/multiple_errors.yml
            rc: 1
            stdout: |
                While scanning
                  in "hitch/test_data/multiple_errors.yml", line 1, column 7:
                    flow: { key: val }
                          ^ (line: 1)
                Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
                  in "hitch/test_data/multiple_errors.yml", line 1, column 8:
                    flow: { key: val }
                           ^ (line: 1)
                ☒ hitch/test_data/multiple_errors.yml
                Encountered 1 error
        - Shell:
            command: cat hitch/test_data/multiple_errors.yml | strictyaml
            shell: sh
            rc: 1
            stdout: |
                While scanning
                  in "<stdin>", line 1, column 7:
                    flow: { key: val }
                          ^ (line: 1)
                Found ugly disallowed JSONesque flow mapping (surround with ' and ' to make text appear literally)
                  in "<stdin>", line 1, column 8:
                    flow: { key: val }
                           ^ (line: 1)
                ☒ <stdin>
                Encountered 1 error
