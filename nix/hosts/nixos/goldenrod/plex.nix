_: {
  flake.nixosModules.goldenrod = _: {
    networking.firewall = {
      allowedTCPPorts = [32400];
      allowedUDPPorts = [1900 32410 32412 32413 32414];
    };
  };
}
