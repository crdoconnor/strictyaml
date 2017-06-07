from subprocess import check_call, call, PIPE, CalledProcessError
from os import path, system, chdir
from commandlib import run, CommandError
import hitchpython
import hitchserve
from hitchstory import StoryCollection, StorySchema, BaseEngine, exceptions
from hitchrun import expected
import signal
from path import Path
from commandlib import Command
import strictyaml
from strictyaml import MapPattern, Str, Map, Int, Optional
from pathquery import pathq
import hitchtest
import hitchdoc

from simex import DefaultSimex
from hitchrun import genpath, hitch_maintenance
from commandlib import python


KEYPATH = Path(__file__).abspath().dirname()
git = Command("git").in_dir(KEYPATH.parent)


class Paths(object):
    def __init__(self, keypath):
        self.genpath = genpath
        self.keypath = keypath
        self.project = keypath.parent
        self.state = keypath.parent.joinpath("state")
        self.engine = keypath



class Engine(BaseEngine):
    """Python engine for running tests."""
    schema = StorySchema(
        preconditions=Map({
            "files": MapPattern(Str(), Str()),
            "variables": MapPattern(Str(), Str()),
            "python version": Str(),
            "ruamel version": Str(),
        }),
        params=Map({
            "python version": Str(),
            "ruamel version": Str(),
        }),
        about={
            "description": Str(),
            Optional("importance"): Int(),
        },
    )

    def __init__(self, keypath, settings):
        self.path = Paths(keypath)
        self.settings = settings


    def set_up(self):
        """Set up your applications and the test environment."""
        self.path.project = self.path.keypath.parent

        self.doc = hitchdoc.Recorder(
            hitchdoc.HitchStory(self),
            self.path.genpath.joinpath('storydb.sqlite'),
        )

        if self.path.state.exists():
            self.path.state.rmtree(ignore_errors=True)
        self.path.state.mkdir()

        for filename, text in self.preconditions.get("files", {}).items():
            filepath = self.path.state.joinpath(filename)
            if not filepath.dirname().exists():
                filepath.dirname().mkdir()
            filepath.write_text(text)

        self.python_package = hitchpython.PythonPackage(
            self.preconditions.get('python_version', '3.5.0')
        )
        self.python_package.build()

        self.pip = self.python_package.cmd.pip
        self.python = self.python_package.cmd.python

        # Install debugging packages
        with hitchtest.monitor([self.path.keypath.joinpath("debugrequirements.txt")]) as changed:
            if changed:
                run(self.pip("install", "-r", "debugrequirements.txt").in_dir(self.path.keypath))

        # Uninstall and reinstall
        run(self.pip("uninstall", "strictyaml", "-y").ignore_errors())
        run(self.pip("install", ".").in_dir(self.path.project))
        run(self.pip("install", "ruamel.yaml=={0}".format(
            self.preconditions["ruamel version"]
        )))

        self.services = hitchserve.ServiceBundle(
            str(self.path.project),
            startup_timeout=8.0,
            shutdown_timeout=1.0
        )

        self.services['IPython'] = hitchpython.IPythonKernelService(self.python_package)

        self.services.startup(interactive=False)
        self.ipython_kernel_filename = self.services['IPython'].wait_and_get_ipykernel_filename()
        self.ipython_step_library = hitchpython.IPythonStepLibrary()
        self.ipython_step_library.startup_connection(self.ipython_kernel_filename)

        #self.assert_true = self.ipython_step_library.assert_true
        #self.assert_exception = self.ipython_step_library.assert_exception
        self.shutdown_connection = self.ipython_step_library.shutdown_connection
        self.ipython_step_library.run("import os")
        self.ipython_step_library.run("import sure")
        self.ipython_step_library.run("from path import Path")
        self.ipython_step_library.run("os.chdir('{}')".format(self.path.state))

        for filename, text in self.preconditions.get("files", {}).items():
            self.ipython_step_library.run(
                """{} = Path("{}").bytes().decode("utf8")""".format(
                    filename.replace(".yaml", ""), filename
                )
            )

    def run_command(self, command):
        self.ipython_step_library.run(command)
        self.doc.step("code", command=command)

    def variable(self, name, value):
        self.path.state.joinpath("{}.yaml".format(name)).write_text(
            value
        )
        self.ipython_step_library.run(
            """{} = Path("{}").bytes().decode("utf8")""".format(
                name, "{}.yaml".format(name)
            )
        )
        self.doc.step("variable", var_name=name, value=value)

    def code(self, command):
        self.ipython_step_library.run(command)
        self.doc.step("code", command=command)

    def raises_exception(self, command, exception, why=''):
        error = self.ipython_step_library.run(
            command, swallow_exception=True
        ).error
        assert exception.strip() in error
        self.doc.step(
            "exception",
            command=command,
            exception=exception,
            why=why,
        )

    def returns_true(self, command, why=''):
        self.ipython_step_library.assert_true(command)
        self.doc.step("true", command=command, why=why)
    
    def should_be_equal(self, lhs='', rhs='', why=''):
        command = """({0}).should.be.equal({1})""".format(lhs, rhs)
        self.ipython_step_library.run(command)
        self.doc.step("true", command=command, why=why)

    def assert_true(self, command):
        self.ipython_step_library.assert_true(command)
        self.doc.step("true", command=command)

    def assert_exception(self, command, exception):
        error = self.ipython_step_library.run(
            command, swallow_exception=True
        ).error
        assert exception.strip() in error
        self.doc.step("exception", command=command, exception=exception)

    def on_failure(self):
        if self.settings.get("pause_on_failure", True):
            if self.preconditions.get("launch_shell", False):
                self.services.log(message=self.stacktrace.to_template())
                self.shell()

    def shell(self):
        if hasattr(self, 'services'):
            self.services.start_interactive_mode()
            import sys
            import time ; time.sleep(0.5)
            if path.exists(path.join(
                path.expanduser("~"), ".ipython/profile_default/security/",
                self.ipython_kernel_filename)
            ):
                call([
                        sys.executable, "-m", "IPython", "console",
                        "--existing", "--no-confirm-exit",
                        path.join(
                            path.expanduser("~"),
                            ".ipython/profile_default/security/",
                            self.ipython_kernel_filename
                        )
                    ])
            else:
                call([
                    sys.executable, "-m", "IPython", "console",
                    "--existing", self.ipython_kernel_filename
                ])
            self.services.stop_interactive_mode()

    def assert_file_contains(self, filename, contents):
        assert self.path.state.joinpath(filename).bytes().decode('utf8').strip() == contents.strip()
        self.doc.step("filename contains", filename=filename, contents=contents)

    def pause(self, message="Pause"):
        if hasattr(self, 'services'):
            self.services.start_interactive_mode()
        import IPython ; IPython.embed()
        if hasattr(self, 'services'):
            self.services.stop_interactive_mode()


    def tear_down(self):
        try:
            self.shutdown_connection()
        except:
            pass
        if hasattr(self, 'services'):
            self.services.shutdown()


@expected(strictyaml.exceptions.YAMLValidationError)
@expected(exceptions.HitchStoryException)
def test(*words):
    """
    Run test with words.
    """
    print(
        StoryCollection(
            pathq(KEYPATH).ext("story"), Engine(KEYPATH, {"overwrite artefacts": True})
        ).shortcut(*words).play().report()
    )


def ci():
    """
    Continuos integration - run all tests and linter.
    """
    #lint()
    print(
        StoryCollection(
            pathq(KEYPATH).ext("story"), Engine(KEYPATH, {})
        ).ordered_by_name().play().report()
    )


def lint():
    """
    Lint all code.
    """
    python("-m", "flake8")(
        KEYPATH.parent.joinpath("strictyaml"),
        "--max-line-length=100",
        "--exclude=__init__.py",
    ).run()
    python("-m", "flake8")(
        KEYPATH.joinpath("key.py"),
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
    version_file = KEYPATH.parent.joinpath("VERSION")
    old_version = version_file.bytes().decode('utf8')
    if version_file.bytes().decode("utf8") != version:
        KEYPATH.parent.joinpath("VERSION").write_text(version)
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
    python("setup.py", "sdist").in_dir(KEYPATH.parent).run()
    python(
        "-m", "twine", "upload", "dist/strictyaml-{0}.tar.gz".format(version)
    ).in_dir(KEYPATH.parent).run()



def docgen():
    """
    Generate documentation.
    """
    docpath = KEYPATH.parent.joinpath("docs")

    if not docpath.exists():
        docpath.mkdir()

    documentation = hitchdoc.Documentation(
        genpath.joinpath('storydb.sqlite'),
        'doctemplates.yml'
    )

    for story in documentation.stories:
        story.write(
            "rst",
            docpath.joinpath("{0}.rst".format(story.slug))
        )
