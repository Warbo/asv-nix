from   asv.environment import Environment
from   asv.console     import log
from   asv             import util
from   json            import dumps
from   os              import path, getcwd
from   subprocess      import check_output, list2cmdline

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
        self._builders     = conf.builders
        self._envdir       = None
        self._python       = python
        self._requirements = requirements

        # Sanity checks
        for key in self._requirements:
            if not key.startswith("nix+"):
                raise NotImplementedError(
                    'TODO: Only requirements beginning with "nix+" supported')

        from distutils import spawn
        if spawn.find_executable("nix-shell") is None:
            raise Exception("Couldn't find nix-shell")
        if spawn.find_executable("nix-build") is None:
            raise Exception("Couldn't find nix-build")

        super(NixEnvironment, self).__init__(conf, python, requirements)

    def _expr(self):
        """
        Returns a Nix expression for building this environment, along with a
        dictionary of arguments which the expression should be called with.
        This is suitable for nix-build's -E, or nix-shell's -p.
        """

        cwd   = dumps(getcwd())

        paths = "[{0}]".format(
            ' '.join(['(({0}) {1} ({2}))'.format(self._builders[key[4:]],
                                                 cwd,
                                                 arg)
                      for (key, arg) in self._requirements.items()]))

        func = '(import <nixpkgs> {}).buildEnv'
        args = 'name = {0}; paths = {1};'.format('"' + self.name + '"',
                                                 paths)

        return func + ' { ' + args + ' }'

    def _setup(self):
        """
        Setup the environment on disk using nix.
        """
        log.info('Building Nix environment')

        self._envdir = check_output(
            ["nix-build", "--show-trace", "--no-out-link", "-E", self._expr()]
        ).strip()
        log.info('Created environment at {0}'.format(self._envdir))

    # Nix projects may not fit asv's assumptions about setup.py, etc. so we make
    # them more conservative
    def build_project(self, repo, commit_hash):
        if path.isfile('setup.py'):
            return super(NixEnvironment, self).build_project(repo, commit_hash)
        log.info('No setup.py so not building')
        return None

    # Nix environments are immutable and build in a single transaction: we can't
    # "install" or "uninstall" things after they're built.

    def install(self, package):
        log.info('Not installing, since Nix is declarative')

    def uninstall(self, package):
        log.info('Not uninstalling, since Nix is declarative')

    def run(self, args, **kwargs):
        """
        Run the python executable from our environment.
        """
        #exe = path.join(self._envdir, 'bin', 'python')
        cmd = list2cmdline(['python'] + args)

        shell = ['nix-shell', '--show-trace', '--pure',
                 '--run', cmd,
                 '-p', self._expr()]

        log.info("Running '{0}' in {1}".format(cmd, self.name))

        return util.check_output(shell, **kwargs)
