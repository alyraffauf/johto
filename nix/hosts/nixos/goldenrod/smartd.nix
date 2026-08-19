_: {
  flake.nixosModules.goldenrod = {
    services = {
      smartd.enable = true;
      prometheus.exporters.smartctl.enable = true;
    };
  };
}
