with { pkgs = import <nixpkgs> {}; };
callPackage ./. (import ./helpers.nix { inherit pkgs; })
