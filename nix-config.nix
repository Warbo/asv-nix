# Provides useful definitions, including asv and withNix
with {
  cfg = (import <nixpkgs> {}).fetchgit {
    url    = "http://chriswarbo.net/git/nix-config.git";
    rev    = "83b4add";
    sha256 = "1zvlr804pkm8pfn7idaygw5japzq0ggk30h2wjq9hj8jb5fkf96g";
  };
};
import <nixpkgs> { config = import "${cfg}/config.nix"; }
