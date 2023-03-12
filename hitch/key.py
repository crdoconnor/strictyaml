from hitchstory import StoryCollection
from strictyaml import Str, Map, Bool, load
from commandlib import Command, python
from click import argument, group, pass_context
from pathquery import pathquery
import hitchpylibrarytoolkit
from engine import Engine
from path import Path
import random
import pyenv


class Directories:
    gen = Path("/gen")
    key = Path("/src/hitch/")
    project = Path("/src/")
    share = Path("/gen")


DIR = Directories()


@group(invoke_without_command=True)
@pass_context
def cli(ctx):
    """Integration test command line interface."""
    pass


PROJECT_NAME = "strictyaml"

toolkit = hitchpylibrarytoolkit.ProjectToolkit(
    "strictyaml",
    DIR,
)

"""
----------------------------
Non-runnable utility methods
---------------------------
"""


def _storybook(**settings):
    return StoryCollection(
        pathquery(DIR.key / "story").ext("story"), Engine(DIR, **settings)
    )


def _current_version():
    return DIR.project.joinpath("VERSION").bytes().decode("utf8").rstrip()


def _personal_settings():
    settings_file = DIR.key.joinpath("personalsettings.yml")

    if not settings_file.exists():
        settings_file.write_text(
            (
                "engine:\n"
                "  rewrite: no\n"
                "  cprofile: no\n"
                "params:\n"
                "  python version: 3.7.0\n"
            )
        )
    return load(
        settings_file.bytes().decode("utf8"),
        Map(
            {
                "engine": Map({"rewrite": Bool(), "cprofile": Bool()}),
                "params": Map({"python version": Str()}),
            }
        ),
    )


def _default_python_version():
    return _personal_settings().data["params"]["python version"]


"""
-----------------
RUNNABLE COMMANDS
-----------------
"""


@cli.command()
@argument("keywords", nargs=-1)
def bdd(keywords):
    """
    Run story matching keywords.
    """
    _storybook().with_params(
        **{"python version": _default_python_version()}
    ).only_uninherited().shortcut(*keywords).play()


@cli.command()
@argument("pyversion", nargs=1)
@argument("keywords", nargs=-1)
def tver(pyversion, keywords):
    """
    Run story against specific version of Python - e.g. tver 3.7.0 modify multi line
    """
    _storybook().with_params(
        **{"python version": pyversion}
    ).only_uninherited().shortcut(*keywords).play()


@cli.command()
@argument("keywords", nargs=-1)
def rbdd(keywords):
    """
    Run story matching keywords and rewrite story if code changed.
    """
    _storybook(rewrite=True).with_params(
        **{"python version": _default_python_version()}
    ).only_uninherited().shortcut(*keywords).play()


@cli.command()
@argument("filename", nargs=1)
def regressfile(filename):
    """
    Run all stories in filename 'filename' in python 3.7.
    """
    _storybook().with_params(**{"python version": "3.7.0"}).in_filename(
        filename
    ).ordered_by_name().play()


@cli.command()
def regression():
    """
    Run regression testing - lint and then run all tests.
    """
    venv = pyenv.devvenv()
    _lint()
    _doctests(venv.python_path)
    storybook = _storybook(python_path=venv.python_path).only_uninherited()
    storybook.with_params(
        **{"python version": venv.py_version.version}
    ).ordered_by_name().play()


@cli.command()
@argument("python_path", nargs=1)
@argument("python_version", nargs=1)
def regression_on_python_path(python_path, python_version):
    """
    Run regression tests - e.g. hk regression_on_python_path /usr/bin/python 3.7.0
    """
    _storybook(python_path=python_path).with_params(
        **{"python version": python_version}
    ).only_uninherited().ordered_by_name().play()


@cli.command()
def checks():
    """
    Run all checks ensure linter, code formatter, tests and docgen all run correctly.

    These checks should prevent code that doesn't have the proper checks run from being merged.
    """
    toolkit.validate_reformatting()
    toolkit.lint(exclude=["__init__.py", "ruamel"])
    _doctests()
    storybook = _storybook().only_uninherited()
    storybook.with_params(**{"python version": "3.7.0"}).ordered_by_name().play()


@cli.command()
def reformat():
    """
    Reformat using black and then relint.
    """
    toolkit.reformat()


@cli.command()
def ipython():
    """
    Run ipython in strictyaml virtualenv.
    """
    DIR.gen.joinpath("example.py").write_text(
        ("from strictyaml import *\n" "import IPython\n" "IPython.embed()\n")
    )
    from commandlib import Command

    version = _personal_settings().data["params"]["python version"]
    Command(DIR.gen.joinpath("py{0}".format(version), "bin", "python"))(
        DIR.gen.joinpath("example.py")
    ).run()


def _lint():
    toolkit.lint(exclude=["__init__.py", "ruamel"])
    assert "\n" not in DIR.project.joinpath("VERSION")


@cli.command()
def lint():
    """
    Lint project code and hitch code.
    """
    _lint()


"""
@cli.command()
def draftdocs():
    run_docgen(DIR, _storybook({}))


@cli.command()
def publishdocs():
    if DIR.gen.joinpath("strictyaml").exists():
        DIR.gen.joinpath("strictyaml").rmtree()

    Path("/root/.ssh/known_hosts").write_text(
        Command("ssh-keyscan", "github.com").output()
    )
    Command("git", "clone", "git@github.com:crdoconnor/strictyaml.git").in_dir(
        DIR.gen
    ).run()

    git = Command("git").in_dir(DIR.gen / "strictyaml")
    git("config", "user.name", "Bot").run()
    git("config", "user.email", "bot@hitchdev.com").run()
    git("rm", "-r", "docs/public").run()

    run_docgen(DIR, _storybook({}), publish=True)

    git("add", "docs/public").run()
    git("commit", "-m", "DOCS : Regenerated docs.").run()

    git("push").run()


@cli.command()
def readmegen():
    run_docgen(DIR, _storybook({}), readme=True)
    DIR.project.joinpath("docs", "draft", "index.md").copy("README.md")
    DIR.project.joinpath("docs", "draft", "changelog.md").copy("CHANGELOG.md")
"""


@cli.command()
@argument("test", nargs=1)
def deploy(test="notest"):
    """
    Deploy to pypi as specified version.
    """
    from commandlib import python

    git = Command("git")

    if DIR.gen.joinpath("strictyaml").exists():
        DIR.gen.joinpath("strictyaml").rmtree()

    git("clone", "git@github.com:crdoconnor/strictyaml.git").in_dir(DIR.gen).run()
    project = DIR.gen / "strictyaml"
    version = project.joinpath("VERSION").text().rstrip()
    initpy = project.joinpath("strictyaml", "__init__.py")
    original_initpy_contents = initpy.bytes().decode("utf8")
    initpy.write_text(original_initpy_contents.replace("DEVELOPMENT_VERSION", version))
    python("-m", "pip", "wheel", ".", "-w", "dist").in_dir(project).run()
    python("-m", "build", "--sdist").in_dir(project).run()
    initpy.write_text(original_initpy_contents)

    # Upload to pypi
    wheel_args = ["-m", "twine", "upload"]
    if test == "test":
        wheel_args += ["--repository", "testpypi"]
    wheel_args += ["dist/{}-{}-py3-none-any.whl".format("strictyaml", version)]

    python(*wheel_args).in_dir(project).run()

    sdist_args = ["-m", "twine", "upload"]
    if test == "test":
        sdist_args += ["--repository", "testpypi"]
    sdist_args += ["dist/{0}-{1}.tar.gz".format("strictyaml", version)]
    python(*sdist_args).in_dir(project).run()

    # Clean up
    DIR.gen.joinpath("strictyaml").rmtree()


@cli.command()
def docgen():
    """
    Build documentation.
    """
    toolkit.docgen(Engine(DIR))


@cli.command()
def readmegen():
    """
    Build README.md and CHANGELOG.md.
    """
    toolkit.readmegen(Engine(DIR))


def _doctests(python_path):
    Command(python_path)(
        "-m", "doctest", "-v", DIR.project.joinpath(PROJECT_NAME, "utils.py")
    ).in_dir(DIR.project.joinpath(PROJECT_NAME)).run()


@cli.command()
def doctests():
    """
    Run doctests in utils.py in latest version.
    """
    _doctests(pyenv.devvenv().python_path)


@cli.command()
def rerun():
    """
    Rerun last example code block with specified version of Python.
    """
    from commandlib import Command

    version = _personal_settings().data["params"]["python version"]
    Command(DIR.gen.joinpath("py{0}".format(version), "bin", "python"))(
        DIR.gen.joinpath("working", "examplepythoncode.py")
    ).in_dir(DIR.gen.joinpath("working")).run()


@cli.command()
def bash():
    """
    Run bash
    """
    from commandlib import Command

    Command("bash").run()


@cli.command()
def cleanpyenv():
    pyenv.Pyenv("/gen/pyenv").clean()


@cli.command()
def sdist():
    """Build sdist"""
    DIR.project.joinpath("dist").rmtree(ignore_errors=True)
    python("setup.py", "sdist").in_dir(DIR.project).run()


@cli.command()
def envirolist():
    pyenv_build = pyenv.Pyenv("/gen/pyenv")
    pyenv_build.ensure_built()

    project_dependencies = pyenv.ProjectDependencies(
        DIR.project.joinpath("pyproject.toml").text(),
        pyenv_build,
    )
    project_dependencies.load()


@cli.command()
@argument("strategy_name", nargs=1)
def envirotest(strategy_name):
    """Run tests on package / python version combinations."""
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
            else 5 + [lambda versions: versions[-2]]
        )
    else:
        raise Exception(f"Strategy name {strategy_name} not found")

    for strategy in strategies:
        venv = pyenv.randomtestvenv(
            picker=strategy,
            package_version=_current_version(),
            pyproject_toml=DIR.project.joinpath("pyproject.toml").text(),
        )
        python_path = venv.python_path
        _doctests(python_path)
        results = (
            _storybook(python_path=python_path)
            .with_params(**{"python version": venv.py_version.version})
            .only_uninherited()
            .ordered_by_name()
            .play()
        )
        assert results.all_passed


@cli.command()
def build():
    pyenv.devvenv()


if __name__ == "__main__":
    cli()
