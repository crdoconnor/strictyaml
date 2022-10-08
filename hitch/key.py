from hitchstory import StoryCollection
from strictyaml import Str, Map, Bool, load
from click import argument, group, pass_context
from pathquery import pathquery
import hitchpylibrarytoolkit
from engine import Engine
from path import Path


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
    _lint()
    _doctests()
    storybook = _storybook().only_uninherited()
    storybook.with_params(**{"python version": "3.7.0"}).ordered_by_name().play()


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


@cli.command()
def lint():
    """
    Lint project code and hitch code.
    """
    _lint()



@cli.command()
def deploy():
    """
    Deploy to pypi as specified version.
    """
    git = Command("git")
    git("clone", "git@github.com:crdoconnor/strictyaml.git").in_dir(DIR.gen).run()
    project = DIR.gen / "strictyaml"
    version = DIR.project.joinpath("VERSION").text().rstrip()
    initpy = DIR.project.joinpath("strictyaml", "__init__.py")
    original_initpy_contents = initpy.bytes().decode("utf8")
    initpy.write_text(
        original_initpy_contents.replace("DEVELOPMENT_VERSION", version)
    )
    python("setup.py", "sdist").in_dir(project).run()
    initpy.write_text(original_initpy_contents)

    # Upload to pypi
    python(
        "-m",
        "twine",
        "upload",
        "dist/{0}-{1}.tar.gz".format("strictyaml", version),
    ).in_dir(project).run()


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


def _doctests():
    for python_version in ["2.7.14", "3.7.0"]:
        pylibrary = hitchpylibrarytoolkit.PyLibraryBuild(
            "strictyaml",
            DIR,
        )
        pylibrary.bin.python(
            "-m", "doctest", "-v", DIR.project.joinpath(PROJECT_NAME, "utils.py")
        ).in_dir(DIR.project.joinpath(PROJECT_NAME)).run()


@cli.command()
def doctests():
    """
    Run doctests in utils.py in python 2 and 3.
    """
    _doctests()


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
def build():
    import hitchpylibrarytoolkit

    hitchpylibrarytoolkit.project_build(
        "strictyaml",
        DIR,
        "3.7.0",
        {"ruamel.yaml": "0.16.5"},
    )


if __name__ == "__main__":
    cli()
