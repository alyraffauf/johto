{
  inputs,
  self,
  ...
}: {
  config.flake.nixosConfigurations.sunnyshore = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.default
      self.nixosModules.sunnyshore
      self.nixosModules.aly
      self.nixosModules.alloy
      self.nixosModules.backups
      self.nixosModules.k3s
      self.nixosModules.prometheusNode
      self.nixosModules.tailscale
      self.nixosModules.wireguardSinnoh
    ];

    specialArgs = {inherit self;};
  };
}
