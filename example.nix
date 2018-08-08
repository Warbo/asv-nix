{ git, pythonPackages, runCommand, withNix, writeScript }:

with builtins;
with rec {
  # Config files and setup scripts to create an example project for asv-nix

  exampleBench = writeScript "benchmarks.py" ''
    import subprocess
    import sys
    def time_bin():
      subprocess.check_call(["foo"])
      sys.stderr.write("Ran foo successfully\n")
  '';

  exampleNix  = writeScript "default.nix" ''
    with import <nixpkgs> {};
    with { foo = writeScript "foo" "#!/usr/bin/env bash\ntrue"; };
    runCommand "foo" { inherit foo; } "mkdir -p $out/bin\ncp $foo $out/bin/foo"
  '';

  exampleConf = writeScript "asv.conf.json" (toJSON {
    # The version of the config file format.  Do not change, unless
    # you know what you are doing.
    version = 1;

    # The actual plugin for using Nix
    plugins = [ "asv_nix" ];

    # Nix expression for building the project. Args include dependencies and the
    # project's directory as 'root'. You should ensure that a `python` binary is
    # included in the result, and that it has access to all your required paths,
    # env vars, etc. (e.g. using makeWrapper).
    installer = ''
      args:
        with args.nixpkgs;
        runCommand "wrapped-python"
          {
            inherit (args) python3;
            foo = import args.root;
            buildInputs = [ makeWrapper ];
          }
          '''
            mkdir -p "$out/bin"
            makeWrapper "$python3"/bin/python3 "$out"/bin/python \
              --prefix PATH : "$foo"/bin
          '''
    '';

    # Named functions used to build Nix-based dependencies. 'args' will include
    # 'dir' as the project directory path, and 'version' as an expression from
    # the corresponding list in "matrix".
    builders = {
      python  = "args: (import <nixpkgs> {}).python";
      nixpkgs = "args: import (args.dir + \"/nixpkgs.nix\")";
    };

    # The name of the project being benchmarked
    project = "test-example";

    # The project's homepage
    project_url = "http://example.org/";

    # The URL or local path of the source code repository for the
    # project being benchmarked
    repo = ".";

    # The tool to use to create environments.  May be "conda",
    # "virtualenv" or other value depending on the plugins in use.
    # If missing or the empty string, the tool will be automatically
    # determined by looking for tools on the PATH environment
    # variable.
    environment_type = "nix";

    # The matrix of dependencies to test.  Each key is the name of an expression
    # in "builders": the resulting Nix function will be called once for each
    # entry in the list of "versions", with each being the 'version' argument.
    matrix = {
      "python"  = [ "null"  ];
      "nixpkgs" = [ "1" "2" ];
    };

    # The directory (relative to the current directory) to cache the Python
    # environments in.  If not provided, defaults to "env"
    env_dir = ".asv/env";

    # The directory (relative to the current directory) that raw benchmark
    # results are stored in.  If not provided, defaults to "results".
    results_dir = ".asv/results";

    # The directory (relative to the current directory) that the html tree
    # should be written to.  If not provided, defaults to "html".
    html_dir = ".asv/html";
  });

  # Generated with `asv machine`
  machineConf = writeScript "asv-machine.json" (toJSON {
    nixos = {
      arch    = "i686";
      cpu     = "Genuine Intel(R) CPU           L2400  @ 1.66GHz";
      machine = "nixos";
      os      = "Linux 4.4.52";
      ram     = "3093764";
    };
    version = 1;
  });

  testSetup = writeScript "test-setup" ''
    #!/usr/bin/env bash
    set -e

    echo "Making dummy asv machine" 1>&2
    mkdir home
    export HOME="$PWD/home"
    cp "${machineConf}" "$HOME/.asv-machine.json"
    chmod +w "$HOME/.asv-machine.json"

    echo "Making dummy git repo" 1>&2
    mkdir test-repo
    pushd test-repo
      git config --global user.email "you@example.com"
      git config --global user.name "Your Name"
      git init
      echo "Foo" > bar
      git add bar
      git commit -m "Initial commit"
      cp "$exampleNix" ./default.nix
      git add default.nix
      git commit -m "Added default.nix"

      echo "Setting up asv in repo" 1>&2
      echo "y" | asv quickstart
      chmod +w -R benchmarks
      cp "$exampleConf"  asv.conf.json
      cp "$exampleBench" benchmarks/benchmarks.py
      echo "import <nixpkgs> {}" > ./nixpkgs.nix
    popd
  '';
};

runCommand "asv-nix-example"
  (withNix {
    inherit exampleBench exampleConf exampleNix machineConf;
    buildInputs = [
      git
      (pythonPackages.python.withPackages (p: [ p.asv p.asv-nix ]))
    ];
  })
  ''
    "${testSetup}"
    export HOME="$PWD/home"
    pushd test-repo
      echo "Running dummy asv benchmarks" 1>&2
      OUT=$(asv run --show-stderr)
      echo "$OUT" | grep 'Ran foo successfully' > /dev/null || {
        echo "$OUT" 1>&2
        echo "Didn't spot success message, aborting" 1>&2
        exit 1
      }

      echo "Generating dummy output" 1>&2
      asv publish

      echo "Repeating, to ensure files can be updated (not read-only)" 1>&2
      asv run
      asv publish

      cp -r .asv/html "$out"
    popd

    [[ -e "$out" ]] || echo "pass" > "$out"
  ''
