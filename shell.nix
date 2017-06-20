with rec {
  origPkgs = import <nixpkgs> {};

  oldCfg = origPkgs.fetchgit {
    url    = "http://chriswarbo.net/git/nix-config.git";
    rev    = "c1530a0";
    sha256 = "01zd9g09h0zmx6af927z7j71yyqvnd09hzlg2r5pcj2rrw8kqs7j";
  };

  oldPkgs = import <nixpkgs> { config = import "${oldCfg}/config.nix"; };

  pkgs = if origPkgs ? asv then origPkgs else oldPkgs.latestCfgPkgs;
};
pkgs.callPackage ./. {}
