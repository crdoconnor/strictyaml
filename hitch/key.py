from hitchstory import HitchStoryException, StoryCollection
from hitchrun import expected
from commandlib import CommandError
from strictyaml import Str, Map, Bool, load
from pathquery import pathquery
from hitchrun import DIR
import dirtemplate
import hitchpylibrarytoolkit
from engine import Engine

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


@expected(HitchStoryException)
def bdd(*keywords):
    """
    Run story matching keywords.
    """
    _storybook().with_params(
        **{"python version": _default_python_version()}
    ).only_uninherited().shortcut(*keywords).play()


@expected(HitchStoryException)
def tver(pyversion, *keywords):
    """
    Run story against specific version of Python - e.g. tver 3.7.0 modify multi line
    """
    _storybook().with_params(
        **{"python version": pyversion}
    ).only_uninherited().shortcut(*keywords).play()


@expected(HitchStoryException)
def rbdd(*keywords):
    """
    Run story matching keywords and rewrite story if code changed.
    """
    _storybook(rewrite=True).with_params(
        **{"python version": _default_python_version()}
    ).only_uninherited().shortcut(*keywords).play()


@expected(HitchStoryException)
def regressfile(filename):
    """
    Run all stories in filename 'filename' in python 2 and 3.
    """
    _storybook().in_filename(filename).with_params(
        **{"python version": "2.7.14"}
    ).filter(
        lambda story: not story.info.get("fails_on_python_2")
    ).ordered_by_name().play()

    _storybook().with_params(**{"python version": "3.7.0"}).in_filename(
        filename
    ).ordered_by_name().play()


@expected(HitchStoryException)
def regression():
    """
    Run regression testing - lint and then run all tests.
    """
    lint()
    doctests()
    storybook = _storybook().only_uninherited()
    storybook.with_params(**{"python version": "2.7.14"}).filter(
        lambda story: not story.info.get("fails_on_python_2")
    ).ordered_by_name().play()
    storybook.with_params(**{"python version": "3.7.0"}).ordered_by_name().play()


@expected(HitchStoryException)
def regression_on_python_path(python_path, python_version):
    """
    Run regression tests - e.g. hk regression_on_python_path /usr/bin/python 3.7.0
    """
    _storybook(python_path=python_path).with_params(
        **{"python version": python_version}
    ).only_uninherited().ordered_by_name().play()


def reformat():
    """
    Reformat using black and then relint.
    """
    toolkit.reformat()


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


@expected(CommandError)
def lint():
    """
    Lint project code and hitch code.
    """
    toolkit.lint()


def deploy(version):
    """
    Deploy to pypi as specified version.
    """
    toolkit.deploy(version)


@expected(dirtemplate.exceptions.DirTemplateException)
def docgen():
    """
    Build documentation.
    """
    toolkit.docgen(Engine(DIR))


@expected(dirtemplate.exceptions.DirTemplateException)
def readmegen():
    """
    Build README.md and CHANGELOG.md.
    """
    toolkit.readmegen(Engine(DIR))


@expected(CommandError)
def doctests():
    """
    Run doctests in utils.py in python 2 and 3.
    """
    for python_version in ["2.7.14", "3.7.0"]:
        pylibrary = hitchpylibrarytoolkit.PyLibraryBuild(
            "strictyaml",
            DIR,
        )
        pylibrary.bin.python(
            "-m", "doctest", "-v", DIR.project.joinpath(PROJECT_NAME, "utils.py")
        ).in_dir(DIR.project.joinpath(PROJECT_NAME)).run()


@expected(CommandError)
def rerun():
    """
    Rerun last example code block with specified version of Python.
    """
    from commandlib import Command

    version = _personal_settings().data["params"]["python version"]
    Command(DIR.gen.joinpath("py{0}".format(version), "bin", "python"))(
        DIR.gen.joinpath("working", "examplepythoncode.py")
    ).in_dir(DIR.gen.joinpath("working")).run()


@expected(CommandError)
def bash():
    """
    Run bash
    """
    from commandlib import Command

    Command("bash").run()


def build():
    import hitchpylibrarytoolkit

    hitchpylibrarytoolkit.project_build(
        "strictyaml",
        DIR,
        "3.7.0",
        {"ruamel.yaml": "0.16.5"},
    )
