{ asv, callPackage, pythonPackages, withDeps, withNix }:

with rec {
  # The actual Python package
  raw = pythonPackages.buildPythonPackage {
    name = "asv-nix";
    src  = ./python;
  };

  # Constructs an example project and tests that everything hooks together
  example = callPackage ./example.nix { inherit asv raw withNix; };
};

# Export the Python package, but add the example as a dependency so that the
# build will abort if it doesn't work
withDeps [ example ] raw
