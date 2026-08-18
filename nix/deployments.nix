{self, ...}: {
  blzrd.nodes = {
    olivine = {
      output = self.nixosConfigurations.olivine.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };

    goldenrod = {
      output = self.nixosConfigurations.goldenrod.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };
  };
}
