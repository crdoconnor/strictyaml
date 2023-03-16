import pyenv
import sys
import random


def run_test(
    pyenv_build,
    pyproject_toml,
    test_package,
    prerequisites,
    strategy_name,
    _storybook,
    _doctests,
):
    if strategy_name == "latest":
        strategies = [
            lambda versions: versions[-1],
        ]
    elif strategy_name == "earliest":
        strategies = [
            lambda versions: versions[0],
        ]
    elif strategy_name in ("full", "maxi"):
        strategies = (
            [
                lambda versions: versions[0],
            ]
            + [random.choice] * 2
            if strategy_name == "full"
            else 5 + [lambda versions: versions[-1]]
        )
    else:
        raise Exception(f"Strategy name {strategy_name} not found")

    for strategy in strategies:
        envirotestvenv = pyenv.EnvirotestVirtualenv(
            pyenv_build=pyenv_build,
            pyproject_toml=pyproject_toml,
            picker=strategy,
            test_package=test_package,
            prerequisites=prerequisites,
        )
        envirotestvenv.build()

        python_path = envirotestvenv.venv.python_path

        _doctests(python_path)
        results = (
            _storybook(python_path=python_path)
            .only_uninherited()
            .ordered_by_name()
            .play()
        )
        if not results.all_passed:
            print("FAILED")
            print("COPY the following into hitch/devenv.yml:\n\n")
            print("python version: {}".format(envirotestvenv.python_version))
            print("packages:")
            for package, version in envirotestvenv.picked_versions.items():
                print("  {}: {}".format(package, version))
            sys.exit(1)
