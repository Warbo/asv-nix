{ path ? <nixpkgs> }:

(import path { overlays = [ (import ./overlay.nix) ]; }).asv-nix-env
