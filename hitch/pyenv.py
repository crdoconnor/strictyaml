from commandlib import CommandPath, Command
from distutils.version import LooseVersion, StrictVersion
from path import Path
import hitchbuild
import requests
import dateutil
from typing import List
import tomli


def package_versions_above(package_name, minimum_version):
    data = requests.get("https://pypi.org/pypi/{}/json".format(package_name)).json()
    versions = list(
        [release for release in data["releases"].keys() if "rc" not in release]
    )
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

    possible_versions = []

    for index, version in enumerate(selected_versions[1:]):
        timediff = upload_dates[version] - upload_dates[selected_versions[index]]

        if timediff.days > 7:
            possible_versions.append(selected_versions[index])

    possible_versions.append(selected_versions[-1])

    return possible_versions


class ProjectDependencies:
    def __init__(self, pyproject_toml, pyenv_build):
        self._pyproject_toml = pyproject_toml
        self._pyenv_build = pyenv_build

    def load(self):
        project = tomli.loads(self._pyproject_toml)["project"]
        pyversion = project["requires-python"]
        dependencies = project["dependencies"]

        self.dependency_versions = {}

        for dependency in dependencies:
            assert ">=" in dependency

            self.dependency_versions[
                dependency.split(">=")[0]
            ] = package_versions_above(
                dependency.split(">=")[0],
                dependency.split(">=")[1],
            )

        self.python_versions = self._pyenv_build.available_versions_above_and_including(
            pyversion.split(">=")[1]
        )


class EnvirotestVirtualenv(hitchbuild.HitchBuild):
    def __init__(
        self, pyenv_build, pyproject_toml, picker, test_package, prerequisites
    ):
        self._pyenv_build = pyenv_build
        self._pyproject_toml = pyproject_toml
        self._picker = picker
        self._test_package = test_package
        self._prerequisites = prerequisites

    def build(self):
        self._pyenv_build.ensure_built()

        project_dependencies = ProjectDependencies(
            self._pyproject_toml,
            self._pyenv_build,
        )
        project_dependencies.load()

        self.python_version = self._picker(project_dependencies.python_versions[:-1])
        print("Python version: {}".format(self.python_version))

        self.picked_versions = {}
        for dependency, versions in project_dependencies.dependency_versions.items():
            self.picked_versions[dependency] = self._picker(versions)
            print("{} version: {}".format(dependency, self.picked_versions[dependency]))

        self.venv = ProjectVirtualenv(
            "randomtestvenv",
            PyVersion(
                self._pyenv_build,
                self.python_version,
            ),
            packages=self._prerequisites
            + [
                PythonRequirements(
                    [
                        "{}=={}".format(library, version)
                        for library, version in self.picked_versions.items()
                    ]
                ),
                self._test_package,
            ],
        )
        self.venv.clean()
        self.venv.ensure_built()


class DevelopmentVirtualenv(hitchbuild.HitchBuild):
    def __init__(
        self,
        pyenv_build,
        versions_file,
        debug_requirements,
        project_path,
        pyproject_toml,
    ):
        self._pyenv_build = pyenv_build
        self._versions_file = versions_file
        self._debug_requirements = debug_requirements
        self._project_path = project_path
        self._pyproject_toml = pyproject_toml

    @property
    def build_path(self):
        return self._pyenv_build.build_path / "versions" / "devvenv"

    @property
    def fingerprint_path(self):
        return self.build_path / "fingerprint.txt"

    @property
    def python_path(self):
        return self.build_path / "bin" / "python"

    def build(self):
        self._pyenv_build.ensure_built()

        if not self.build_path.exists():
            if not self._versions_file.exists():
                project_dependencies = ProjectDependencies(
                    self._pyproject_toml,
                    self._pyenv_build,
                )
                project_dependencies.load()

                self.python_version = project_dependencies.python_versions[:-1][-1]

                self.picked_versions = {}
                for (
                    dependency,
                    versions,
                ) in project_dependencies.dependency_versions.items():
                    self.picked_versions[dependency] = versions[-1]
            else:
                from strictyaml import load

                devenv = load(self._versions_file.text()).data
                self.python_version = devenv["python version"]
                self.picked_versions = devenv["packages"]

            self.venv = ProjectVirtualenv(
                "devvenv",
                PyVersion(
                    self._pyenv_build,
                    self.python_version,
                ),
                packages=[
                    PythonRequirements(
                        ["ensure", "python-slugify"],
                    ),
                    PythonRequirements(
                        [
                            "{}=={}".format(library, version)
                            for library, version in self.picked_versions.items()
                        ]
                    ),
                    PythonProjectDirectory(self._project_path),
                ],
            )
            self.venv.ensure_built()
            self.refingerprint()


class PythonPackage:
    pass


class PythonVersionDependentRequirement(PythonPackage):
    def __init__(
        self, package, lower_version, python_version_threshold, higher_version
    ):
        self._package = package
        self._lower_version = lower_version
        self._python_version_threshold = LooseVersion(python_version_threshold)
        self._higher_version = higher_version

    def install(self, venv):
        if LooseVersion(venv.py_version.version) > self._python_version_threshold:
            venv.pip("install", "{}={}".format(self._package, self._higher_version))
        else:
            venv.pip("install", "{}={}".format(self._package, self._lower_version))


class PythonRequirementsFile(PythonPackage):
    def __init__(self, requirements_file):
        self.requirements_file = requirements_file

    def install(self, venv):
        venv.pip("install", "-r", self.requirements_file).run()


class PythonRequirements(PythonPackage):
    def __init__(self, requirements: List[str], test_repo=False):
        self.requirements = requirements
        self._test_repo = test_repo

    def install(self, venv):
        for requirement in self.requirements:
            if self._test_repo:
                venv.pip(
                    "install",
                    "--no-build-isolation",
                    "--index-url",
                    "https://test.pypi.org/simple/",
                    requirement,
                ).run()
            else:
                venv.pip("install", requirement).run()


class PythonProjectPackage(PythonPackage):
    def __init__(self, package_filename):
        self.package_filename = package_filename

    def install(self, venv):
        local_install_output = venv.pip("install", self.package_filename).output()

        if "DEPRECATION" in local_install_output:
            raise Exception("DEPRECATION ERROR:\n {}".format(local_install_output))


class PythonProjectDirectory(PythonPackage):
    def __init__(self, project_directory):
        self.project_directory = project_directory

    def install(self, venv):
        venv.pip("install", "-e", self.project_directory).run()


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
                    package.install(self)

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
