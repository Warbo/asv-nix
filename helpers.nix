{ pkgs ? import <nixpkgs> {} }:
{
  helpers = pkgs.nix-helpers or import (pkgs.fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
  });
    rev    = "ed8379a";
    sha256 = "1ifyz49x9ck3wkfw3r3yy8s0vcknz937bh00033zy6r1a2alg54g";

  packages = pkgs.warbo-packages or import (pkgs.fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "c2ea27d";
    sha256 = "04aif1s3cxk27nybsxp571fmvswy5vbw0prq67y108sb49mm3288";
  });
}
