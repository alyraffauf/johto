_: {
  flake.nixosModules.default = _: {
    networking.networkmanager.enable = true;
  };
}
