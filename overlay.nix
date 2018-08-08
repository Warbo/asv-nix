# 'self' and 'super' are nixpkgs, 'pelf' and 'puper' are Python package sets
self: super:

with import ./helpers.nix { pkgs = self; };
with rec {
  # A Python package set override for adding asv-nix, and asv if it's not there
  addAsvNix = pelf: puper: {
    asv     = puper.asv or (packages.asv.override { pythonPackages = pelf; });
    asv-nix = self.callPackage ./derivation.nix { pythonPackages = pelf; };
  };

  # A Python package set override which adds an extra dependency to asv-nix. The
  # dependency constructs an example project to check that everything hooks
  # together and works.
  # Note that this requires the Python package set to contain asv and asv-nix.
  addTest = pelf: puper:
    with {
      example = self.callPackage ./example.nix {
        inherit (helpers) withNix;
        pythonPackages = puper;
      };
    };
    {
      asv-nix = helpers.withDeps [ example ] puper.asv-nix;
    };

  # Combines the above Python package overrides, to expose a tested asv-nix
  pythonPackageOverrides = self.lib.composeExtensions addTest addAsvNix;

  # A particular Python package/set with our overrides
  pythonWithOverrides = super.python3.override (old: {
    packageOverrides = self.lib.composeExtensions
      (old.packageOverrides or (_: _: {}))
      pythonPackageOverrides;
  });
};
{
  inherit pythonPackageOverrides;

  # Expose asv-nix (and asv, if not found) as standalone packages
  inherit (pythonWithOverrides.pythonPackages) asv-nix;
  asv = super.asv or pythonWithOverrides.pythonPackages.asv;

  # Also provide a self-contained asv and asv-nix Python binary
  asv-nix-env = pythonWithOverrides.withPackages (p: [
    p.asv p.asv-nix
  ]);
}
