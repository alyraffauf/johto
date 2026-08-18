_: {
  flake.nixosModules.olivine = {self, ...}: {
    hardware.facter.reportPath = self + "/nix/hosts/nixos/olivine/facter.json";
  };
}
