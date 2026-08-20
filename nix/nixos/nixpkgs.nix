{sharedPackageSets, ...}: {
  flake.nixosModules.default = {
    lib,
    self,
    ...
  }: {
    nixpkgs.pkgs = lib.mkDefault sharedPackageSets.x86_64-linux;
    system.configurationRevision = self.rev or self.dirtyRev or null;
  };
}
