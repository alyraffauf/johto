{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.cherrygrove = {
    lib,
    ...
  }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
      self.nixosModules.default
      self.nixosModules.aly
    ];

    nixpkgs.pkgs = lib.mkForce (import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      overlays = [self.overlays.default];
    });
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
