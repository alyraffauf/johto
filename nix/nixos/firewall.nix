_: {
  flake.nixosModules.default = {
    networking.firewall.allowedTCPPorts = [80 443];
  };
}
