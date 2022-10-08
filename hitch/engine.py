from hitchstory import (
    StoryCollection,
    BaseEngine,
    exceptions,
    validate,
    no_stacktrace_for,
)
from hitchstory import GivenDefinition, GivenProperty, InfoDefinition, InfoProperty
from templex import Templex
from strictyaml import Optional, Str, Map, Int, Bool, Enum, load
from path import Path
import hitchpylibrarytoolkit
from hitchrunpy import (
    ExamplePythonCode,
    HitchRunPyException,
    ExpectedExceptionMessageWasDifferent,
)


CODE_TYPE = Map({"in python 2": Str(), "in python 3": Str()}) | Str()


class Engine(BaseEngine):
    """Python engine for running tests."""

    given_definition = GivenDefinition(
        yaml_snippet=GivenProperty(
            Str(), document="yaml_snippet:\n```yaml\n{{ yaml_snippet }}\n```"
        ),
        yaml_snippet_1=GivenProperty(
            Str(), document="yaml_snippet_1:\n```yaml\n{{ yaml_snippet_1 }}\n```"
        ),
        yaml_snippet_2=GivenProperty(
            Str(), document="yaml_snippet_2:\n```yaml\n{{ yaml_snippet_2 }}\n```"
        ),
        modified_yaml_snippet=GivenProperty(
            Str(),
            document="modified_yaml_snippet:\n```yaml\n{{ modified_yaml_snippet }}\n```",
        ),
        python_version=GivenProperty(Str()),
        ruamel_version=GivenProperty(Str()),
        setup=GivenProperty(Str(), document="```python\n{{ setup }}\n```"),
    )

    info_definition = InfoDefinition(
        status=InfoProperty(schema=Enum(["experimental", "stable"])),
        docs=InfoProperty(schema=Str()),
        fails_on_python_2=InfoProperty(schema=Bool()),
        description=InfoProperty(schema=Str()),
        experimental=InfoProperty(schema=Bool()),
    )

    def __init__(self, keypath, python_path=None, rewrite=False, cprofile=False):
        self.path = keypath
        self._python_path = python_path
        self._rewrite = rewrite
        self._cprofile = cprofile

    def set_up(self):
        """Set up your applications and the test environment."""
        self.path.profile = self.path.gen.joinpath("profile")

        if not self.path.profile.exists():
            self.path.profile.mkdir()

        if not self._python_path:
            self.pylibrary = (
                hitchpylibrarytoolkit.PyLibraryBuild("strictyaml", self.path)
                .with_python_version(self.given["python version"])
                .with_packages({"ruamel.yaml": self.given["ruamel version"]})
            )
            self.pylibrary.ensure_built()
            self.python = self.pylibrary.bin.python
        else:
            self.python = Path(self._python_path)
            assert self.python.exists()

        self.example_py_code = (
            ExamplePythonCode(self.python, self.path.gen)
            .with_code(self.given.get("code", ""))
            .with_setup_code(self.given.get("setup", ""))
            .with_terminal_size(160, 100)
            .with_strings(
                yaml_snippet_1=self.given.get("yaml_snippet_1"),
                yaml_snippet=self.given.get("yaml_snippet"),
                yaml_snippet_2=self.given.get("yaml_snippet_2"),
                modified_yaml_snippet=self.given.get("modified_yaml_snippet"),
            )
        )

    @no_stacktrace_for(AssertionError)
    @no_stacktrace_for(HitchRunPyException)
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
            if self.given["python version"].startswith("3"):
                code = "{0}\nprint(repr({1}))".format(
                    "\n".join(code.strip().split("\n")[:-1]),
                    code.strip().split("\n")[-1],
                )
            else:
                code = "{0}\nprint repr({1})".format(
                    "\n".join(code.strip().split("\n")[:-1]),
                    code.strip().split("\n")[-1],
                )

        to_run = self.example_py_code.with_code(code)

        if self._cprofile:
            to_run = to_run.with_cprofile(
                self.path.profile.joinpath("{0}.dat".format(self.story.slug))
            )

        if raises is None:
            result = (
                to_run.expect_exceptions().run() if raises is not None else to_run.run()
            )

            if will_output is not None:
                actual_output = "\n".join(
                    [line.rstrip() for line in result.output.split("\n")]
                )
                try:
                    Templex(will_output).assert_match(actual_output)
                except AssertionError:
                    if self._rewrite:
                        self.current_step.update(**{"will output": actual_output})
                    else:
                        raise

        elif raises is not None:
            differential = False  # Difference between Python 2 and Python 3 output?
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
                result = to_run.expect_exceptions().run()
                result.exception_was_raised(exception_type, message)
            except ExpectedExceptionMessageWasDifferent as error:
                if self._rewrite and not differential:
                    new_raises = raises.copy()
                    new_raises["message"] = result.exception.message
                    self.current_step.update(raises=new_raises)
                else:
                    raise

    def pause(self, message="Pause"):
        import IPython

        IPython.embed()

    def on_success(self):
        if self._rewrite:
            self.new_story.save()
        if self._cprofile:
            self.python(
                self.path.key.joinpath("printstats.py"),
                self.path.profile.joinpath("{0}.dat".format(self.story.slug)),
            ).run()
