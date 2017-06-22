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
            Either a dependency called 'python', or irrelevant.
        requirements : dict
            Dictionary mapping a "builder" name to a "version" expression.
        """

        # User-provided Nix expressions, for building the dependencies and
        # project, respectively
        self._builders     = conf.builders
        self._installer    = conf.installer

        # This will be set to a Nix build result after "install"
        self._envdir       = None

        # Required by asv, but unused since "installer" will provide Python
        self._python       = ''

        # The arguments for each builder
        self._requirements = requirements

        # asv special-cases 'python'; undo it
        if 'python' in conf.matrix:
            self._requirements['python'] = python

        # Sanity checks
        from distutils import spawn
        if spawn.find_executable("nix-build") is None:
            raise Exception("Couldn't find nix-build")

        super(NixEnvironment, self).__init__(conf, python, requirements)

    def _expr(self):
        """
        Returns a Nix expression for building this environment, suitable for
        nix-build's -E, or nix-shell's -p.
        """
        cwd = dumps(getcwd())

        def requirement(key, arg):
            func = self._builders[key]
            args = 'dir = {0}; version = {1};'.format(cwd, arg)
            return '((' + func + ') { ' + args + ' })'

        args = '; '.join(
            ['{0} = {1}'.format(k, requirement(k, v))
             for (k, v) in self._requirements.items()] +
            ['root = "' + self._build_root + '"']) + ';'

        return '((' + self._installer + ') { ' + args + ' })'

    def _setup(self):
        """
        Nix builds environments atomically: we can't set up an environment and
        then install into it; instead we build the whole thing in 'install'.
        """
        return

    def build_project(self, repo, commit_hash):
        self.checkout_project(repo, commit_hash)
        return None

    def install(self, package):
        # Build the checked-out project and its dependencies
        self._envdir = util.check_output(
            ['nix-build', '--show-trace', '--no-out-link', '-E', self._expr()],
            cwd=self._build_root
        ).strip()

    def uninstall(self, package):
        self._envdir = None

    def run(self, args, **kwargs):
        """
        Run the python executable from our environment.
        """
        if self._envdir is None:
            raise Exception('Cannot run without env dir')

        return util.check_output(
            [path.join(self._envdir, 'bin', 'python')] + args, **kwargs)
