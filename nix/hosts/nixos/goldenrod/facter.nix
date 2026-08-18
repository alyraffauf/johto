_: {
  flake.nixosModules.goldenrod = {self, ...}: {
    hardware.facter.reportPath = self + "/nix/hosts/nixos/goldenrod/facter.json";
  };
}
