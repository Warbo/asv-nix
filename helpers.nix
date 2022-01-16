{ pkgs ? import <nixpkgs> {} }:
{
  helpers = pkgs.nix-helpers or (import (builtins.fetchGit {
    url = http://chriswarbo.net/git/nix-helpers.git;
    ref = "master";
    rev = "12ae13b1bb28d891f2cf54e0a9c34f7f2caf5b88";
  }));

  packages = pkgs.warbo-packages or (import (builtins.fetchGit {
    url = http://chriswarbo.net/git/warbo-packages.git;
    ref = "master";
    rev = "3d2187ef874ba62275d43c2a26c715ca8d1119ad";
  }));
}
