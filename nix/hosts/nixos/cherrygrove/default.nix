{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.cherrygrove = {
    imports = [
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.default
      self.nixosModules.aly
    ];
  };

  flake.nixosConfigurations.cherrygrove = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    modules = [
      inputs.microvm.nixosModules.microvm
      self.nixosModules.cherrygrove
    ];

    specialArgs = {inherit self;};
  };
}
