{ pythonPackages, stdenv }:

pythonPackages.buildPythonPackage {
  name        = "asv-nix";
  src         = ./python;
  buildInputs = [ pythonPackages.asv ];
  doCheck     = !stdenv.isDarwin;
}
