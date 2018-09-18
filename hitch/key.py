from hitchstory import StoryCollection, StorySchema, BaseEngine, HitchStoryException
from hitchstory import validate, expected_exception
from hitchrun import expected
from commandlib import Command, CommandError
from strictyaml import Str, Map, Int, Bool, Optional, load
from pathquery import pathquery
from hitchrun import DIR
from hitchrun.decorators import ignore_ctrlc
from hitchrunpy import (
    ExamplePythonCode,
    HitchRunPyException,
    ExpectedExceptionMessageWasDifferent,
)
from templex import Templex, NonMatching
import dirtemplate
import hitchpylibrarytoolkit


CODE_TYPE = Map({"in python 2": Str(), "in python 3": Str()}) | Str()


class Engine(BaseEngine):
    """Python engine for running tests."""

    schema = StorySchema(
        given={
            Optional("yaml_snippet"): Str(),
            Optional("yaml_snippet_1"): Str(),
            Optional("yaml_snippet_2"): Str(),
            Optional("modified_yaml_snippet"): Str(),
            Optional("python version"): Str(),
            Optional("ruamel version"): Str(),
            Optional("setup"): Str(),
            Optional("code"): Str(),
        },
        info={
            Optional("description"): Str(),
            Optional("importance"): Int(),
            Optional("experimental"): Bool(),
            Optional("docs"): Str(),
            Optional("fails on python 2"): Bool(),
        },
    )

    def __init__(self, keypath, settings):
        self.path = keypath
        self.settings = settings

    def set_up(self):
        """Set up your applications and the test environment."""
        self.path.state = self.path.gen.joinpath("state")
        if self.path.state.exists():
            self.path.state.rmtree(ignore_errors=True)
        self.path.state.mkdir()

        self.path.profile = self.path.gen.joinpath("profile")

        if not self.path.profile.exists():
            self.path.profile.mkdir()

        self.python = hitchpylibrarytoolkit.project_build(
            "strictyaml",
            self.path,
            self.given["python version"],
            {"ruamel.yaml": self.given["ruamel version"]},
        ).bin.python

        self.example_py_code = (
            ExamplePythonCode(self.python, self.path.state)
            .with_code(self.given.get("code", ""))
            .with_setup_code(self.given.get("setup", ""))
            .with_terminal_size(160, 100)
            .with_long_strings(
                yaml_snippet_1=self.given.get("yaml_snippet_1"),
                yaml_snippet=self.given.get("yaml_snippet"),
                yaml_snippet_2=self.given.get("yaml_snippet_2"),
                modified_yaml_snippet=self.given.get("modified_yaml_snippet"),
            )
        )

    @expected_exception(NonMatching)
    @expected_exception(HitchRunPyException)
    @validate(
        code=Str(),
        will_output=Map({"in python 2": Str(), "in python 3": Str()}) | Str(),
        raises=Map({Optional("type"): CODE_TYPE, Optional("message"): CODE_TYPE}),
        in_interpreter=Bool(),
    )
    def run(
        self,
        code,
        will_output=None,
        yaml_output=True,
        raises=None,
        in_interpreter=False,
    ):
        if in_interpreter:
            code = "{0}\nprint(repr({1}))".format(
                "\n".join(code.strip().split("\n")[:-1]), code.strip().split("\n")[-1]
            )
        to_run = self.example_py_code.with_code(code)

        if self.settings.get("cprofile"):
            to_run = to_run.with_cprofile(
                self.path.profile.joinpath("{0}.dat".format(self.story.slug))
            )

        result = (
            to_run.expect_exceptions().run() if raises is not None else to_run.run()
        )

        if will_output is not None:
            actual_output = "\n".join(
                [line.rstrip() for line in result.output.split("\n")]
            )
            try:
                Templex(will_output).assert_match(actual_output)
            except NonMatching:
                if self.settings.get("rewrite"):
                    self.current_step.update(**{"will output": actual_output})
                else:
                    raise

        if raises is not None:
            differential = False  # Difference between python 2 and python 3 output?
            exception_type = raises.get("type")
            message = raises.get("message")

            if exception_type is not None:
                if not isinstance(exception_type, str):
                    differential = True
                    exception_type = (
                        exception_type["in python 2"]
                        if self.given["python version"].startswith("2")
                        else exception_type["in python 3"]
                    )

            if message is not None:
                if not isinstance(message, str):
                    differential = True
                    message = (
                        message["in python 2"]
                        if self.given["python version"].startswith("2")
                        else message["in python 3"]
                    )

            try:
                result = self.example_py_code.expect_exceptions().run()
                result.exception_was_raised(exception_type, message)
            except ExpectedExceptionMessageWasDifferent as error:
                if self.settings.get("rewrite") and not differential:
                    new_raises = raises.copy()
                    new_raises["message"] = result.exception.message
                    self.current_step.update(raises=new_raises)
                else:
                    raise

    def pause(self, message="Pause"):
        import IPython

        IPython.embed()

    def on_success(self):
        if self.settings.get("rewrite"):
            self.new_story.save()
        if self.settings.get("cprofile"):
            self.python(
                self.path.key.joinpath("printstats.py"),
                self.path.profile.joinpath("{0}.dat".format(self.story.slug)),
            ).run()


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
                "  python version: 3.5.0\n"
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


@expected(HitchStoryException)
def bdd(*keywords):
    """
    Run stories matching keywords.
    """
    settings = _personal_settings().data
    _storybook(settings["engine"]).with_params(
        **{"python version": settings["params"]["python version"]}
    ).only_uninherited().shortcut(*keywords).play()


@expected(HitchStoryException)
def rbdd(*keywords):
    """
    Run stories matching keywords.
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

    Rewrite stories if appropriate.
    """
    _storybook({"rewrite": False}).in_filename(filename).with_params(
        **{"python version": "2.7.14"}
    ).filter(lambda story: not story.info["fails on python 2"]).ordered_by_name().play()

    _storybook({"rewrite": False}).with_params(
        **{"python version": "3.5.0"}
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
        lambda story: not story.info["fails on python 2"]
    ).ordered_by_name().play()
    storybook.with_params(**{"python version": "3.5.0"}).ordered_by_name().play()


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


@expected(CommandError)
def doctests():
    for python_version in ["2.7.14", "3.5.0"]:
        pylibrary = hitchpylibrarytoolkit.project_build(
            "strictyaml", DIR, python_version
        )
        pylibrary.bin.python(
            "-m", "doctest", "-v", DIR.project.joinpath("strictyaml", "utils.py")
        ).in_dir(DIR.project.joinpath("strictyaml")).run()


@ignore_ctrlc
def ipy():
    """
    Run IPython in environment."
    """
    Command(DIR.gen.joinpath("py3.5.0", "bin", "ipython")).run()


def hvenvup(package, directory):
    """
    Install a new version of a package in the hitch venv.
    """
    pip = Command(DIR.gen.joinpath("hvenv", "bin", "pip"))
    pip("uninstall", package, "-y").run()
    pip("install", DIR.project.joinpath(directory).abspath()).run()


def rerun(version="3.5.0"):
    """
    Rerun last example code block with specified version of python.
    """
    Command(DIR.gen.joinpath("py{0}".format(version), "bin", "python"))(
        DIR.gen.joinpath("state", "examplepythoncode.py")
    ).in_dir(DIR.gen.joinpath("state")).run()
