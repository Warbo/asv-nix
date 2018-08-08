self: super:

with import ./helpers.nix { pkgs = self; };
{
  inherit (packages) asv;
  asv-nix-plugin = self.newScope (helpers // packages) ./derivation.nix {};
  asv-nix        = with self; python.withPackages (p: [ asv asv-nix-plugin ]);
}
