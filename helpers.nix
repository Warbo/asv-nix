{ pkgs ? import <nixpkgs> {} }:
{
  helpers = pkgs.nix-helpers or import (pkgs.fetchgit {
    url    = http://chriswarbo.net/git/nix-helpers.git;
    rev    = "3354810";
    sha256 = "0xzv515v68hspps6q8hbf1y7lsamp2bdkkp7rk94f6722mmjihwa";
  });

  packages = pkgs.warbo-packages or import (pkgs.fetchgit {
    url    = http://chriswarbo.net/git/warbo-packages.git;
    rev    = "c2ea27d";
    sha256 = "04aif1s3cxk27nybsxp571fmvswy5vbw0prq67y108sb49mm3288";
  });
}
