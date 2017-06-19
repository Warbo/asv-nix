{ asv, git, pythonPackages, stdenv, withNix, writeScript }:

with rec {
  raw = pythonPackages.buildPythonPackage {
    name = "asv-nix";
    src  = ./python;
  };

  example = stdenv.mkDerivation (withNix {
    inherit exampleConf machineConf;
    name = "asv-nix-example";
    buildInputs = [ asv git raw ];

    buildCommand = ''
      mkdir home
      export HOME="$PWD/home"
      cp "$machineConf" "$HOME/.asv-machine.json"
      chmod +w "$HOME/.asv-machine.json"

      mkdir test-repo
      pushd test-repo
        git config --global user.email "you@example.com"
        git config --global user.name "Your Name"
        git init
        echo "Foo" > bar
        git add bar
        git commit -m "Initial commit"

        yes | asv quickstart || true
        cp "$exampleConf" asv.conf.json
        asv run
      popd
      exit 1
    '';
  });

  exampleConf = writeScript "asv.conf.json" ''
    {
        // The version of the config file format.  Do not change, unless
        // you know what you are doing.
        "version": 1,

        // The actual plugin for using Nix
        "plugins": [ "asv_nix" ],

        // The name of the project being benchmarked
        "project": "test-example",

        // The project's homepage
        "project_url": "http://example.org/",

        // The URL or local path of the source code repository for the
        // project being benchmarked
        "repo": ".",

        // The tool to use to create environments.  May be "conda",
        // "virtualenv" or other value depending on the plugins in use.
        // If missing or the empty string, the tool will be automatically
        // determined by looking for tools on the PATH environment
        // variable.
        "environment_type": "nix",

        // The matrix of dependencies to test.  Each key is the name of a
        // package (in PyPI) and the values are version numbers.  An empty
        // list or empty string indicates to just test against the default
        // (latest) version. null indicates that the package is to not be
        // installed. If the package to be tested is only available from
        // PyPi, and the 'environment_type' is conda, then you can preface
        // the package name by 'pip+', and the package will be installed via
        // pip (with all the conda available packages installed first,
        // followed by the pip installed packages).
        //
        // "matrix": {
        //     "numpy": ["1.6", "1.7"],
        //     "six": ["", null],        // test with and without six installed
        //     "pip+emcee": [""],   // emcee is only available for install with pip.
        // },

        // Combinations of libraries/python versions can be excluded/included
        // from the set to test. Each entry is a dictionary containing additional
        // key-value pairs to include/exclude.
        //
        // An exclude entry excludes entries where all values match. The
        // values are regexps that should match the whole string.
        //
        // An include entry adds an environment. Only the packages listed
        // are installed. The 'python' key is required. The exclude rules
        // do not apply to includes.
        //
        // In addition to package names, the following keys are available:
        //
        // - python
        //     Python version, as in the *pythons* variable above.
        // - environment_type
        //     Environment type, as above.
        // - sys_platform
        //     Platform, as in sys.platform. Possible values for the common
        //     cases: 'linux2', 'win32', 'cygwin', 'darwin'.
        //
        // "exclude": [
        //     {"python": "3.2", "sys_platform": "win32"}, // skip py3.2 on windows
        //     {"environment_type": "conda", "six": null}, // don't run without six on conda
        // ],
        //
        // "include": [
        //     // additional env for python2.7
        //     {"python": "2.7", "numpy": "1.8"},
        //     // additional env if run on windows+conda
        //     {"platform": "win32", "environment_type": "conda", "python": "2.7", "libpython": ""},
        // ],

        // The directory (relative to the current directory) to cache the Python
        // environments in.  If not provided, defaults to "env"
        "env_dir": ".asv/env",

        // The directory (relative to the current directory) that raw benchmark
        // results are stored in.  If not provided, defaults to "results".
        "results_dir": ".asv/results",

        // The directory (relative to the current directory) that the html tree
        // should be written to.  If not provided, defaults to "html".
        "html_dir": ".asv/html",
    }
  '';

  # Generated with `asv machine`
  machineConf = writeScript "asv-machine.json" ''
    {
        "nixos": {
            "arch": "i686",
            "cpu": "Genuine Intel(R) CPU           L2400  @ 1.66GHz",
            "machine": "nixos",
            "os": "Linux 4.4.52",
            "ram": "3093764"
        },
        "version": 1
    }
  '';
};
raw.override (old: {
  # Forces example to be checked first
  inherit example;
})
