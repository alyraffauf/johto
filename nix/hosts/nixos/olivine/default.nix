{
  inputs,
  self,
  ...
}: {
  config.flake.nixosConfigurations.olivine = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.default
      self.nixosModules.autoUpgrade
      self.nixosModules.olivine
      self.nixosModules.aly
      self.nixosModules.alloy
      self.nixosModules.backups
      self.nixosModules.k3s
      self.nixosModules.prometheusNode
      self.nixosModules.tailscale
      self.nixosModules.wireguardJohto
    ];

    specialArgs = {inherit self;};
  };
}
