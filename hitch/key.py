from commandlib import run
import hitchpython
from hitchstory import StoryCollection, StorySchema, BaseEngine, exceptions, validate
from hitchrun import expected
from commandlib import Command
from strictyaml import MapPattern, Str, Map, Int, Optional, load
from pathquery import pathq
import hitchtest
import hitchdoc
from hitchrun import hitch_maintenance
from commandlib import python
from hitchrun import DIR
from hitchrun.decorators import ignore_ctrlc
from hitchrunpy import ExamplePythonCode, ExpectedExceptionMessageWasDifferent
import requests


class Engine(BaseEngine):
    """Python engine for running tests."""
    schema = StorySchema(
        preconditions=Map({
            Optional("files"): MapPattern(Str(), Str()),
            Optional("variables"): MapPattern(Str(), Str()),
            Optional("yaml_snippet"): Str(),
            Optional("modified_yaml_snippet"): Str(),
            Optional("python version"): Str(),
            Optional("ruamel version"): Str(),
            Optional("setup"): Str(),
            Optional("code"): Str(),
        }),
        params=Map({
            Optional("python version"): Str(),
            Optional("ruamel version"): Str(),
        }),
        about={
            Optional("description"): Str(),
            Optional("importance"): Int(),
        },
    )

    def __init__(self, keypath, settings):
        self.path = keypath
        self.settings = settings

    def set_up(self):
        """Set up your applications and the test environment."""
        self.doc = hitchdoc.Recorder(
            hitchdoc.HitchStory(self),
            self.path.gen.joinpath('storydb.sqlite'),
        )

        self.path.state = self.path.gen.joinpath("state")
        if self.path.state.exists():
            self.path.state.rmtree(ignore_errors=True)
        self.path.state.mkdir()

        self.python_package = hitchpython.PythonPackage(
            self.preconditions['python version']
        )
        self.python_package.build()

        self.pip = self.python_package.cmd.pip
        self.python = self.python_package.cmd.python

        # Install debugging packages
        with hitchtest.monitor([self.path.key.joinpath("debugrequirements.txt")]) as changed:
            if changed:
                run(self.pip("install", "-r", "debugrequirements.txt").in_dir(self.path.key))

        # Uninstall and reinstall
        with hitchtest.monitor(
            pathq(self.path.project.joinpath("strictyaml")).ext("py")
        ) as changed:
            if changed:
                run(self.pip("uninstall", "strictyaml", "-y").ignore_errors())
                run(self.pip("install", ".").in_dir(self.path.project))
                run(self.pip("install", "ruamel.yaml=={0}".format(
                    self.preconditions["ruamel version"]
                )))

        self.example_py_code = ExamplePythonCode(self.preconditions.get('code', ''))\
            .with_setup_code(self.preconditions.get('setup', ''))\
            .with_long_strings(
                yaml_snippet=self.preconditions.get('yaml_snippet'),
                modified_yaml_snippet=self.preconditions.get('modified_yaml_snippet'),
            )

    @validate(
        exception_type=Map({"in python 2": Str(), "in python 3": Str()}) | Str(),
        message=Map({"in python 2": Str(), "in python 3": Str()}) | Str(),
    )
    def raises_exception(self, exception_type=None, message=None):
        """
        Expect an exception.
        """
        differential = False

        if exception_type is not None:
            if not isinstance(exception_type, str):
                differential = True
                exception_type = exception_type['in python 2']\
                    if self.preconditions['python version'].startswith("2")\
                    else exception_type['in python 3']

        if message is not None:
            if not isinstance(message, str):
                differential = True
                message = message['in python 2']\
                    if self.preconditions['python version'].startswith("2")\
                    else message['in python 3']

        try:
            result = self.example_py_code.expect_exceptions().run(self.path.state, self.python)
            result.exception_was_raised(exception_type, message)
        except ExpectedExceptionMessageWasDifferent as error:
            if self.settings.get("rewrite") and not differential:
                self.current_step.update(message=error.actual_message)
            else:
                raise

    def should_be_equal_to(self, rhs):
        """
        Code should be equal to rhs
        """
        self.example_py_code = ExamplePythonCode(self.preconditions['setup'])\
            .with_long_strings(
                yaml_snippet=self.preconditions.get('yaml_snippet'),
                modified_yaml_snippet=self.preconditions.get('modified_yaml_snippet'),
            )\
            .is_equal(self.preconditions.get("code"), rhs)\
            .run(self.path.state, self.python)

    def pause(self, message="Pause"):
        import IPython
        IPython.embed()

    def on_success(self):
        if self.settings.get("rewrite"):
            self.new_story.save()


def _storybook(settings):
    return StoryCollection(pathq(DIR.key).ext("story"), Engine(DIR, settings))


@expected(exceptions.HitchStoryException)
def tdd(*words):
    """
    Run all tests
    """
    print(
        _storybook({"rewrite": True}).shortcut(*words).play().report()
    )


@expected(exceptions.HitchStoryException)
def testfile(filename):
    """
    Run all stories in filename 'filename'.
    """
    print(
        _storybook({"rewrite": True}).in_filename(filename).ordered_by_name().play().report()
    )


@expected(exceptions.HitchStoryException)
def regression():
    """
    Run regression testing - lint and then run all tests.
    """
    lint()
    print(
        _storybook({}).ordered_by_name().play().report()
    )


def lint():
    """
    Lint all code.
    """
    python("-m", "flake8")(
        DIR.project.joinpath("strictyaml"),
        "--max-line-length=100",
        "--exclude=__init__.py",
    ).run()
    python("-m", "flake8")(
        DIR.key.joinpath("key.py"),
        "--max-line-length=100",
        "--exclude=__init__.py",
    ).run()
    print("Lint success!")


def hitch(*args):
    """
    Use 'h hitch --help' to get help on these commands.
    """
    hitch_maintenance(*args)


def deploy(version):
    """
    Deploy to pypi as specified version.
    """
    NAME = "strictyaml"
    git = Command("git").in_dir(DIR.project)
    version_file = DIR.project.joinpath("VERSION")
    old_version = version_file.bytes().decode('utf8')
    if version_file.bytes().decode("utf8") != version:
        DIR.project.joinpath("VERSION").write_text(version)
        git("add", "VERSION").run()
        git("commit", "-m", "RELEASE: Version {0} -> {1}".format(
            old_version,
            version
        )).run()
        git("push").run()
        git("tag", "-a", version, "-m", "Version {0}".format(version)).run()
        git("push", "origin", version).run()
    else:
        git("push").run()

    # Set __version__ variable in __init__.py, build sdist and put it back
    initpy = DIR.project.joinpath(NAME, "__init__.py")
    original_initpy_contents = initpy.bytes().decode('utf8')
    initpy.write_text(
        original_initpy_contents.replace("DEVELOPMENT_VERSION", version)
    )
    python("setup.py", "sdist").in_dir(DIR.project).run()
    initpy.write_text(original_initpy_contents)

    # Upload to pypi
    python(
        "-m", "twine", "upload", "dist/{0}-{1}.tar.gz".format(NAME, version)
    ).in_dir(DIR.project).run()


def docgen():
    """
    Generate documentation.
    """
    docpath = DIR.project.joinpath("docs")

    if not docpath.exists():
        docpath.mkdir()

    documentation = hitchdoc.Documentation(
        DIR.gen.joinpath('storydb.sqlite'),
        'doctemplates.yml'
    )

    for story in documentation.stories:
        story.write(
            "rst",
            docpath.joinpath("{0}.rst".format(story.slug))
        )


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


def rot():
    """
    Test for code rot by upgrading dependency and running tests (ruamel.yaml).
    """
    print("Checking code rot for strictyaml project...")
    latest_version = requests.get(
        "https://pypi.python.org/pypi/ruamel.yaml/json"
    ).json()['info']['version']
    base_story = load(DIR.key.joinpath("strictyaml.story").bytes().decode("utf8"))
    latest_tested_version = str(base_story['strictyaml']['params']['ruamel version'])

    if latest_version != latest_tested_version:
        base_story['strictyaml']['params']['ruamel version'] = load(latest_version)
        DIR.key.joinpath("strictyaml.story").write_text(base_story.as_yaml())
        regression()
    else:
        print("No dependency changes")
