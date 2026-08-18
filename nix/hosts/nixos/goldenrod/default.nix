{
  inputs,
  self,
  ...
}: {
  config.flake.nixosConfigurations.goldenrod = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      inputs.determinate.nixosModules.default
      inputs.disko.nixosModules.disko
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.default
      self.nixosModules.goldenrod
      self.nixosModules.aly
      self.nixosModules.alloy
      self.nixosModules.backups
      self.nixosModules.b2media
      self.nixosModules.k3s
      self.nixosModules.lanzaboote
      self.nixosModules.prometheusNode
      self.nixosModules.tailscale
      self.nixosModules.wireguardJohto
    ];

    specialArgs = {inherit self;};
  };
}
