from hitchstory import HitchStoryException, StoryCollection
from hitchrun import expected
from commandlib import CommandError
from strictyaml import Str, Map, Bool, load
from pathquery import pathquery
from hitchrun import DIR
import dirtemplate
import hitchpylibrarytoolkit
from engine import Engine

"""
----------------------------
Non-runnable utility methods
---------------------------
"""


def _storybook(settings):
    return StoryCollection(pathquery(DIR.key).ext("story"), Engine(DIR, settings))


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
    settings = _personal_settings().data
    _storybook(settings["engine"]).with_params(
        **{"python version": settings["params"]["python version"]}
    ).only_uninherited().shortcut(*keywords).play()


@expected(HitchStoryException)
def rbdd(*keywords):
    """
    Run story matching keywords and rewrite story if code changed.
    """
    settings = _personal_settings().data
    settings["engine"]["rewrite"] = True
    _storybook(settings["engine"]).with_params(
        **{"python version": settings["params"]["python version"]}
    ).only_uninherited().shortcut(*keywords).play()


@expected(HitchStoryException)
def regressfile(filename):
    """
    Run all stories in filename 'filename' in python 2 and 3.
    """
    _storybook({"rewrite": False}).in_filename(filename).with_params(
        **{"python version": "2.7.14"}
    ).filter(
        lambda story: not story.info.get("fails_on_python_2")
    ).ordered_by_name().play()

    _storybook({"rewrite": False}).with_params(
        **{"python version": "3.7.0"}
    ).in_filename(filename).ordered_by_name().play()


@expected(HitchStoryException)
def regression():
    """
    Run regression testing - lint and then run all tests.
    """
    lint()
    doctests()
    storybook = _storybook({}).only_uninherited()
    storybook.with_params(**{"python version": "2.7.14"}).filter(
        lambda story: not story.info.get("fails_on_python_2")
    ).ordered_by_name().play()
    storybook.with_params(**{"python version": "3.7.0"}).ordered_by_name().play()


def reformat():
    """
    Reformat using black and then relint.
    """
    hitchpylibrarytoolkit.reformat(DIR.project, "strictyaml")


def lint():
    """
    Lint project code and hitch code.
    """
    hitchpylibrarytoolkit.lint(DIR.project, "strictyaml")


def deploy(version):
    """
    Deploy to pypi as specified version.
    """
    hitchpylibrarytoolkit.deploy(DIR.project, "strictyaml", version)


@expected(dirtemplate.exceptions.DirTemplateException)
def docgen():
    """
    Build documentation.
    """
    hitchpylibrarytoolkit.docgen(_storybook({}), DIR.project, DIR.key, DIR.gen)


@expected(dirtemplate.exceptions.DirTemplateException)
def readmegen():
    """
    Build documentation.
    """
    hitchpylibrarytoolkit.readmegen(
        _storybook({}), DIR.project, DIR.key, DIR.gen, "strictyaml"
    )


@expected(CommandError)
def doctests():
    """
    Run doctests in utils.py in python 2 and 3.
    """
    for python_version in ["2.7.14", "3.7.0"]:
        pylibrary = hitchpylibrarytoolkit.project_build(
            "strictyaml", DIR, python_version
        )
        pylibrary.bin.python(
            "-m", "doctest", "-v", DIR.project.joinpath("strictyaml", "utils.py")
        ).in_dir(DIR.project.joinpath("strictyaml")).run()


@expected(CommandError)
def rerun(version="3.7.0"):
    """
    Rerun last example code block with specified version of python.
    """
    from commandlib import Command

    Command(DIR.gen.joinpath("py{0}".format(version), "bin", "python"))(
        DIR.gen.joinpath("state", "examplepythoncode.py")
    ).in_dir(DIR.gen.joinpath("state")).run()
