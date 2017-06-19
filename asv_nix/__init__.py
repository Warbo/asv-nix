from asv.environment import Environment
import subprocess

def requirements_string(reqs):
    """Turns asv 'requirements' into a list of Nix expressions"""
    return "[ bash ]"

class NixEnvironment(Environment):
    tool_name = "nix"

    def __init__(self, conf, python, requirements):
        """
        Parameters
        ----------
        conf : Config instance
        python : str
            Version of Python.  Must be of the form "MAJOR.MINOR".
        executable : str
            Path to Python executable.
        requirements : dict
            Dictionary mapping a PyPI package name to a version
            identifier string.
        """
        self._python = python
        self._requirements = requirements
        super(NixEnvironment, self).__init__(conf, python, requirements)

    def _setup(self):
        """
        Setup the environment on disk using nix.
        Then, all of the requirements are installed into
        it using `pip install`.
        """
        print(subprocess.check_output([
            "nix-build",
            "-E",
            'with import <nixpkgs> {}; buildEnv { name = "asv-nix-env"; paths = ' +
            requirements_string(self._requirements) +
            '; }']))
