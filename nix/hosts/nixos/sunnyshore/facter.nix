_: {
  flake.nixosModules.sunnyshore = {self, ...}: {
    hardware.facter.reportPath = self + "/nix/hosts/nixos/sunnyshore/facter.json";
  };
}
