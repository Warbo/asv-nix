{ pythonPackages }:

pythonPackages.buildPythonPackage {
  name = "asv-nix";
  src  = ./python;
  buildInputs = [ pythonPackages.asv ];
}
