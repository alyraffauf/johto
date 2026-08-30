_: {
  flake.nixosModules.goldenrod = _: {
    networking.firewall = {
      allowedTCPPorts = [6881];
      allowedUDPPorts = [6881];
    };
  };
}
