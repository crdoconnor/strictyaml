from commandlib import CommandPath, Command
from distutils.version import LooseVersion, StrictVersion
from path import Path
import hitchbuild
import requests
import dateutil
from typing import List


def clean():
    Pyenv("/gen/pyenv").clean()


class ProjectVersions:
    def __init__(self, filename, pyenv_build):
        self._filename = filename
        self._pyenv_build = pyenv_build

    def load(self):
        import tomli

        project = tomli.loads(Path(filename).text())["project"]
        pyversion = project["requires-python"]
        dependencies = project["dependencies"]


def randomtestvenv(picker=None, local_package=None):
    pyenv_build = Pyenv("/gen/pyenv")
    pyenv_build.ensure_built()

    python_dateutil_version = picker(package_versions_above("python-dateutil", "2.6.0"))
    python_version = picker(pyenv_build.available_versions_above_and_including("3.7.0"))
    print("Dateutil version: {}".format(python_dateutil_version))
    print("Python version: {}".format(python_version))

    pyversion = PyVersion(
        pyenv_build,
        python_version,
    )

    venv = ProjectVirtualenv(
        "randomtestvenv",
        pyversion,
        # requirements_files=[],
        # requirements=[
        # "ensure",
        # "python-slugify",
        # "python-dateutil=={}".format(python_dateutil_version),
        # ],
        # local_package=local_package,
        packages=[
            PythonRequirements(
                ["ensure", "python-slugify"],
            ),
            PythonProjectPackage(local_package),
            PythonRequirements(
                [
                    "python-dateutil=={}".format(python_dateutil_version),
                ]
            ),
        ],
    )
    venv.clean()
    venv.ensure_built()
    return venv


def devvenv():
    pyenv_build = Pyenv("/gen/pyenv")
    pyenv_build.ensure_built()

    pyversion = PyVersion(
        pyenv_build,
        pyenv_build.available_versions_above_and_including("3.7.0")[-2],
    )

    venv = ProjectVirtualenv(
        "devenv",
        pyversion,
        packages=[
            PythonRequirementsFile("/src/hitch/debugrequirements.txt"),
            PythonProjectDirectory("/src"),
        ],
    )
    venv.ensure_built()
    return venv


def package_versions_above(package_name, minimum_version):
    data = requests.get("https://pypi.org/pypi/{}/json".format(package_name)).json()
    versions = list(data["releases"].keys())
    versions.sort(key=StrictVersion)

    selected_versions = [
        version
        for version in versions
        if LooseVersion(version) >= LooseVersion(minimum_version)
    ]

    upload_dates = {
        version: dateutil.parser.parse(data["releases"][version][-1]["upload_time"])
        for version in selected_versions
    }

    relevant_versions = []

    for index, version in enumerate(selected_versions[1:]):
        timediff = upload_dates[version] - upload_dates[selected_versions[index]]

        if timediff.days > 7:
            relevant_versions.append(selected_versions[index])

    relevant_versions.append(selected_versions[-1])

    return relevant_versions


class PythonPackage:
    pass


class PythonRequirementsFile(PythonPackage):
    def __init__(self, requirements_file):
        self.requirements_file = requirements_file

    def install(self, pip):
        pip("install", "-r", self.requirements_file).run()


class PythonRequirements(PythonPackage):
    def __init__(self, requirements: List[str]):
        self.requirements = requirements

    def install(self, pip):
        for requirement in self.requirements:
            pip("install", requirement).run()


class PythonProjectPackage(PythonPackage):
    def __init__(self, package_filename):
        self.package_filename = package_filename

    def install(self, pip):
        local_install_output = pip("install", self.package_filename).output()

        if "DEPRECATION" in local_install_output:
            raise Exception("DEPRECATION ERROR:\n {}".format(local_install_output))


class PythonProjectDirectory(PythonPackage):
    def __init__(self, project_directory):
        self.project_directory = project_directory

    def install(self, pip):
        pip("install", "-e", self.project_directory).run()


class ProjectVirtualenv(hitchbuild.HitchBuild):
    def __init__(
        self,
        venv_name,
        py_version,
        requirements=None,
        requirements_files=None,
        package_dir=None,
        local_package=None,
        packages=None,
    ):
        self.venv_name = venv_name
        self.py_version = py_version
        self.requirements_files = requirements_files
        self.requirements = requirements
        self.package_dir = package_dir
        self.local_package = local_package
        self.packages = packages
        self.build_path = (
            self.py_version.pyenv_build.build_path / "versions" / self.venv_name
        )
        self.fingerprint_path = self.build_path / "fingerprint.txt"

    @property
    def pyenv(self):
        return self.py_version.pyenv_build.pyenv

    @property
    def python_path(self):
        return self.build_path / "bin" / "python"

    def clean(self):
        try:
            self.build_path.readlink().rmtree(ignore_errors=True)
            self.build_path.remove()
        except FileNotFoundError:
            pass

    @property
    def pip(self):
        return Command(self.build_path / "bin" / "pip")

    def build(self):
        if not self.build_path.exists():
            self.py_version.ensure_built()
            self.pyenv("virtualenv", self.py_version.version, self.venv_name).run()

            if self.packages is not None:
                for package in self.packages:
                    package.install(self.pip)

            self.refingerprint()


class PyVersion(hitchbuild.HitchBuild):
    def __init__(self, pyenv_build, version):
        self.pyenv_build = pyenv_build
        self.version = version
        self.build_path = self.pyenv_build.build_path / "versions" / self.version
        self.fingerprint_path = self.build_path / "fingerprint.txt"

    def clean(self):
        self.build_path.rmtree(ignore_errors=True)

    def build(self):
        if not self.build_path.exists():
            self.pyenv_build.ensure_built()
            self.pyenv_build.pyenv("install", self.version).run()
            self.refingerprint()


class Pyenv(hitchbuild.HitchBuild):
    def __init__(self, build_path):
        self.build_path = Path(build_path).abspath()
        self.fingerprint_path = self.build_path / "fingerprint.txt"

    @property
    def bin(self):
        return CommandPath(self.build_path / "bin")

    def clean(self):
        self.build_path.rmtree(ignore_errors=True)

    @property
    def pyenv(self):
        return Command(self.bin.pyenv).with_env(PYENV_ROOT=self.build_path)

    def available_versions_above_and_including(self, minimum_version):
        return [
            version.strip()
            for version in self.pyenv("install", "-l").output().split("\n")
            if version.strip().startswith("3")
            and "dev" not in version
            and LooseVersion(version.strip()) >= LooseVersion(minimum_version)
        ]

    def build(self):
        if self.incomplete():
            self.build_path.rmtree(ignore_errors=True)
            self.build_path.mkdir()
            Command(
                "git", "clone", "https://github.com/pyenv/pyenv.git", self.build_path
            ).run()
            Command(
                "git",
                "clone",
                "https://github.com/pyenv/pyenv-virtualenv.git",
                self.build_path / "plugins" / "pyenv-virtualenv",
            ).run()
            self.refingerprint()
