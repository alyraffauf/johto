_: {
  flake.nixosModules.prometheusNode = {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = ["systemd"];
      port = 3021;
    };
  };
}
