from hitchstory import StoryCollection, StorySchema, BaseEngine, HitchStoryException
from hitchstory import validate, expected_exception
from hitchrun import expected
from commandlib import Command, CommandError, python
from strictyaml import Str, Map, Int, Bool, Optional, load
from pathquery import pathq
from hitchrun import hitch_maintenance
from hitchrun import DIR
from hitchrun.decorators import ignore_ctrlc
from hitchrunpy import ExamplePythonCode, HitchRunPyException, ExpectedExceptionMessageWasDifferent
import requests
from templex import Templex, NonMatching
from path import Path
import hitchbuildpy
import dirtemplate


def project_build(paths, python_version, ruamel_version=None):
    pylibrary = hitchbuildpy.PyLibrary(
        name="py{0}".format(python_version),
        base_python=hitchbuildpy.PyenvBuild(python_version)
                                .with_build_path(paths.share),
        module_name="strictyaml",
        library_src=paths.project,
    ).with_requirementstxt(
        paths.key/"debugrequirements.txt"
    ).with_build_path(paths.gen)

    if ruamel_version is not None:
        pylibrary = pylibrary.with_packages(
            "ruamel.yaml=={0}".format(ruamel_version)
        )

    pylibrary.ensure_built()
    return pylibrary


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

        self.python = project_build(
            self.path,
            self.given['python version'],
            self.given['ruamel version'],
        ).bin.python

        self.example_py_code = ExamplePythonCode(self.python, self.path.state)\
            .with_code(self.given.get('code', ''))\
            .with_setup_code(self.given.get('setup', ''))\
            .with_terminal_size(160, 100)\
            .with_long_strings(
                yaml_snippet_1=self.given.get('yaml_snippet_1'),
                yaml_snippet=self.given.get('yaml_snippet'),
                yaml_snippet_2=self.given.get('yaml_snippet_2'),
                modified_yaml_snippet=self.given.get('modified_yaml_snippet'),
            )

    @expected_exception(NonMatching)
    @expected_exception(HitchRunPyException)
    @validate(
        code=Str(),
        will_output=Map({"in python 2": Str(), "in python 3": Str()}) | Str(),
        raises=Map({
            Optional("type"): Map({"in python 2": Str(), "in python 3": Str()}) | Str(),
            Optional("message"): Map({"in python 2": Str(), "in python 3": Str()}) | Str(),
        }),
        in_interpreter=Bool(),
    )
    def run(self, code, will_output=None, yaml_output=True, raises=None, in_interpreter=False):
        if in_interpreter:
            code = '{0}\nprint(repr({1}))'.format(
                '\n'.join(code.strip().split('\n')[:-1]),
                code.strip().split('\n')[-1]
            )
        to_run = self.example_py_code.with_code(code)

        if self.settings.get("cprofile"):
            to_run = to_run.with_cprofile(
                self.path.profile.joinpath("{0}.dat".format(self.story.slug))
            )

        result = to_run.expect_exceptions().run() if raises is not None else to_run.run()

        if will_output is not None:
            actual_output = '\n'.join([line.rstrip() for line in result.output.split("\n")])
            try:
                Templex(will_output).assert_match(actual_output)
            except NonMatching:
                if self.settings.get("rewrite"):
                    self.current_step.update(**{"will output": actual_output})
                else:
                    raise

        if raises is not None:
            differential = False  # Difference between python 2 and python 3 output?
            exception_type = raises.get('type')
            message = raises.get('message')

            if exception_type is not None:
                if not isinstance(exception_type, str):
                    differential = True
                    exception_type = exception_type['in python 2']\
                        if self.given['python version'].startswith("2")\
                        else exception_type['in python 3']

            if message is not None:
                if not isinstance(message, str):
                    differential = True
                    message = message['in python 2']\
                        if self.given['python version'].startswith("2")\
                        else message['in python 3']

            try:
                result = self.example_py_code.expect_exceptions().run()
                result.exception_was_raised(exception_type, message)
            except ExpectedExceptionMessageWasDifferent as error:
                if self.settings.get("rewrite") and not differential:
                    new_raises = raises.copy()
                    new_raises['message'] = result.exception.message
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
                self.path.profile.joinpath("{0}.dat".format(self.story.slug))
            ).run()


def _storybook(settings):
    return StoryCollection(pathq(DIR.key).ext("story"), Engine(DIR, settings))


def _current_version():
    return DIR.project.joinpath("VERSION").bytes().decode('utf8').rstrip()


def _personal_settings():
    settings_file = DIR.key.joinpath("personalsettings.yml")

    if not settings_file.exists():
        settings_file.write_text((
            "engine:\n"
            "  rewrite: no\n"
            "  cprofile: no\n"
            "params:\n"
            "  python version: 3.5.0\n"
        ))
    return load(
        settings_file.bytes().decode('utf8'),
        Map({
            "engine": Map({
                "rewrite": Bool(),
                "cprofile": Bool(),
            }),
            "params": Map({
                "python version": Str(),
            }),
        })
    )


@expected(HitchStoryException)
def bdd(*keywords):
    """
    Run stories matching keywords.
    """
    settings = _personal_settings().data
    _storybook(settings['engine'])\
        .with_params(**{"python version": settings['params']['python version']})\
        .only_uninherited()\
        .shortcut(*keywords).play()


@expected(HitchStoryException)
def regressfile(filename):
    """
    Run all stories in filename 'filename' in python 2 and 3.

    Rewrite stories if appropriate.
    """
    _storybook({"rewrite": False}).in_filename(filename)\
                                  .with_params(**{"python version": "2.7.10"})\
                                  .filter(lambda story: not story.info['fails on python 2'])\
                                  .ordered_by_name().play()

    _storybook({"rewrite": False}).with_params(**{"python version": "3.5.0"})\
                                  .in_filename(filename).ordered_by_name().play()


@expected(HitchStoryException)
def regression():
    """
    Run regression testing - lint and then run all tests.
    """
    lint()
    doctest()
    storybook = _storybook({}).only_uninherited()
    storybook.with_params(**{"python version": "2.7.10"})\
             .filter(lambda story: not story.info['fails on python 2'])\
             .ordered_by_name().play()
    storybook.with_params(**{"python version": "3.5.0"}).ordered_by_name().play()


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


@expected(dirtemplate.exceptions.DirTemplateException)
def docgen():
    """
    Build documentation.
    """
    template = dirtemplate.DirTemplate(
        "docs",
        DIR.project/"docs",
        DIR.gen,
    ).with_files(
        story_md={"story": {}},
    )
    template.ensure_built()


def old_docgen():
    """
    Generate documentation.
    """
    from copy import copy

    class Page(object):
        def __init__(self, filename):
            self._filename = filename

    class TemplatedDocumentation(object):
        def __init__(self, source_path):
            self._source_path = source_path
            self._template_vars = {}

        def with_vars(self, **template_vars):
            new_templated_docs = copy(self)
            new_templated_docs._template_vars = template_vars
            return new_templated_docs

        def _templated_vars(self):
            return self._template_vars

        def render_to(self, build_path):
            self._path.copytree(build_path)

            for template in pathq(build_path).ext("jinja2"):
                print("Rendering template {0}".format(template))
                Path(template.replace(".jinja2", "")).write_text(
                    Template(template.text()).render(**self._templated_vars)
                )
                template.remove()

    docs = DIR.gen.joinpath("docs")
    if docs.exists():
        docs.rmtree(ignore_errors=True)

    # Copy in non-generated docs
    DIR.project.joinpath("docs").copytree(docs)

    using = docs.joinpath("using", "alpha")
    for story in _storybook({}).with_templates(
        load(DIR.key.joinpath("doctemplates.yml").bytes().decode('utf8')).data
    ).ordered_by_name():
        if story.info['docs']:
            doc = using.joinpath("{0}.md".format(story.info['docs']))
            if not doc.dirname().exists():
                doc.dirname().makedirs()
            doc.write_text(story.documentation())

    readme = DIR.project.joinpath("docs", "index.md.jinja2").text()
    from jinja2.environment import Environment
    from jinja2 import DictLoader, Template

    env = Environment()
    env.loader = DictLoader({"README": readme})

    def list_dirs(directory, docdir):
        pages = []

        for filepath in pathq(directory):
            if not filepath.isdir() and filepath.basename() not in ('index.jinja2', 'index.md'):
                relpath = filepath.relpath(docdir)
                pages.append({
                    "name": load(filepath.text().split('---')[1])['title'].data,
                    "slug": relpath.dirname().joinpath(relpath.namebase).lstrip("/"),
                })
        return pages

    def categories(pages):
        cat = {}
        for page in pages:
            levels = page['slug'].split('/')

            subcat = cat
            for level in levels[:-1]:
                if level not in subcat:
                    subcat[level] = {}
                subcat = subcat[level]
            subcat[levels[-1]] = page
        return cat

    doc_template_vars = {
        "url": "http://hitchdev.com/strictyaml",
        "quickstart": _storybook({}).with_templates(
            load(DIR.key.joinpath("doctemplates.yml").bytes().decode('utf8')).data
        ).in_filename(DIR.key/"quickstart.story").non_variations().ordered_by_file(),
        "why": list_dirs(DIR.project/"docs"/"why", DIR.project/"docs"),
        "why_not": list_dirs(DIR.project/"docs"/"why-not", DIR.project/"docs"),
        "using": list_dirs(docs/"using"/"alpha", docs),
        "using_categories": categories(list_dirs(docs/"using"/"alpha", docs)),
        "readme": False,
    }

    for template in pathq(docs).ext("jinja2"):
        print("Rendering template {0}".format(template))
        Path(template.replace(".jinja2", "")).write_text(
            Template(template.text()).render(**doc_template_vars)
        )
        template.remove()

    doc_template_vars["readme"] = True

    readme_text = env.get_template("README").render(**doc_template_vars)

    import re
    for match in re.compile("\[.*?\]\(.*?\)").findall(readme_text):
        if "http://" not in match and "https://" not in match:
            readme_text = readme_text.replace(
                match,
                re.sub(
                    "\[(.*?)\]\((.*?)\)",
                    r"[\1](http://hitchdev.com/strictyaml/\2)",
                    match
                )
            )

    DIR.gen.joinpath("README.md").write_text(readme_text)


@expected(CommandError)
def doctest():
    pylibrary = project_build(DIR, "2.7.10")
    pylibrary.bin.python(
        "-m", "doctest", "-v", DIR.project.joinpath("strictyaml", "utils.py")
    ).in_dir(DIR.project.joinpath("strictyaml")).run()

    pylibrary = project_build(DIR, "3.5.0")
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
