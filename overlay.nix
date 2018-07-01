self: super:

with import ./helpers.nix { pkgs = self; };
{
  asv-nix = self.newScope (helpers // packages) ./derivation.nix {};
}
