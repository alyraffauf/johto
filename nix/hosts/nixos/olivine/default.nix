{
  inputs,
  self,
  ...
}: {
  config = {
    flake.nixosConfigurations.olivine = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        inputs.determinate.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
        self.nixosModules.alloy
        self.nixosModules.aly
        self.nixosModules.backups
        self.nixosModules.comin
        self.nixosModules.default
        self.nixosModules.k3s
        self.nixosModules.olivine
        self.nixosModules.prometheusNode
        self.nixosModules.tailscale
        self.nixosModules.wireguardJohto
      ];

      specialArgs = {inherit self;};
    };

    blzrd.nodes.olivine = {
      output = self.nixosConfigurations.olivine.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };
  };
}
