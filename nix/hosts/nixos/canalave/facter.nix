_: {
  flake.nixosModules.canalave = {self, ...}: {
    hardware.facter.reportPath = self + "/nix/hosts/nixos/canalave/facter.json";
  };
}
