from subprocess import check_call, call, PIPE, CalledProcessError
from os import path, system, chdir
from commandlib import run, CommandError
import hitchpython
import hitchserve
import hitchtest
import hitchcli
import signal


class ExecutionEngine(hitchtest.ExecutionEngine):
    """Python engine for running tests."""

    def set_up(self):
        """Set up your applications and the test environment."""
        self.path.project = self.path.engine.parent
        self.path.docs = self.path.project.joinpath("docs")
        self.path.this_story_doc = self.path.docs.joinpath(
            "{0}.rst".format(path.basename(self._test.filename).replace(".test", ""))
        )

        if self.path.this_story_doc.exists():
            self.path.this_story_doc.remove()
        self.append_to_docs("{0}\n{1}\n\n".format(
                self._test.name, "=" * len(self._test.name),
            )
        )

        if self._test.description is not None:
            self.append_to_docs("{0}\n\n".format(self._test.description))

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
        with hitchtest.monitor([self.path.engine.joinpath("debugrequirements.txt")]) as changed:
            if changed:
                run(self.pip("install", "-r", "debugrequirements.txt").in_dir(self.path.engine))

        # Uninstall and reinstall
        run(self.pip("uninstall", "strictyaml", "-y").ignore_errors())
        run(self.pip("install", ".").in_dir(self.path.project))
        run(self.pip("install", "ruamel.yaml=={0}".format(self.preconditions.get("ruamel version", "0.12.12"))))

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
        self.ipython_step_library.run("from path import Path")
        self.ipython_step_library.run("os.chdir('{}')".format(self.path.state))

        for filename, text in self.preconditions.get("files", {}).items():
            self.ipython_step_library.run(
                """{} = Path("{}").bytes().decode("utf8")""".format(
                    filename.replace(".yaml", ""), filename
                )
            )
            self.append_to_docs("{0}\n.. code-block:: yaml\n\n  {1}\n\n".format(
                filename.replace(".yaml", ""),
                text.rstrip("\n").replace("\n", "\n  ")
            ))

    def run_command(self, command):
        self.ipython_step_library.run(command)
        self.append_to_docs(
            ".. code-block:: python\n\n  >>> {0}\n\n".format(
                command.rstrip("\n").replace("\n", "\n  >>> ")
            )
        )

    def assert_true(self, command):
        self.ipython_step_library.assert_true(command)
        self.append_to_docs(
            ".. code-block:: python\n\n  >>> {0}\n  True\n\n".format(
                command.rstrip("\n").replace("\n", "\n  >>> ")
            )
        )

    def assert_exception(self, command, exception):
        self.ipython_step_library.assert_exception(command, exception)
        self.append_to_docs(
            ".. code-block:: python\n\n  >>> {0}\n  EXCEPTION RAISED:\n  {1}\n\n".format(
                command.rstrip("\n").replace("\n", "\n  >>> "),
                exception.rstrip("\n").replace("\n", "\n  "),
            )
        )

    def append_to_docs(self, text):
        self.path.this_story_doc.write_text(text, append=True)

    def on_failure(self):
        if self.settings.get("pause_on_failure", True):
            if self.preconditions.get("launch_shell", True):
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
                        "--existing",
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

    def flake8(self, directory, args=None):
        # Silently install flake8
        self.services.start_interactive_mode()
        flake8 = self.python_package.cmd.flake8
        try:
            run(flake8(str(self.path.project.joinpath(directory)), *args).in_dir(self.path.project))
        except CommandError:
            raise RuntimeError("flake8 failure")

    def pause(self, message="Pause"):
        if hasattr(self, 'services'):
            self.services.start_interactive_mode()
        self.ipython(message)
        if hasattr(self, 'services'):
            self.services.stop_interactive_mode()


    def tear_down(self):
        try:
            self.shutdown_connection()
        except:
            pass
        if hasattr(self, 'services'):
            self.services.shutdown()
