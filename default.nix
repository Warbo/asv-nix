{ asv, callPackage, pythonPackages }:

with rec {
  # The actual Python package
  raw = pythonPackages.buildPythonPackage {
    name = "asv-nix";
    src  = ./python;
    propagatedBuildInputs = [ asv ];
  };

  # Constructs an example project and tests that everything hooks together
  example = callPackage ./example.nix { inherit raw; };
};

# Export the Python package, but add the example as a dependency so that the
# build will abort if it doesn't work
raw.override (old: { inherit example; })
