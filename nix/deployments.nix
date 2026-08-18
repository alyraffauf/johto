{self, ...}: {
  blzrd.nodes = {
    sunnyshore = {
      output = self.nixosConfigurations.sunnyshore.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };

    canalave = {
      output = self.nixosConfigurations.canalave.config.system.build.toplevel;
      type = "nixos";
      user = "root";
    };
  };
}
