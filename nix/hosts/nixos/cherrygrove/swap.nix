_: {
  flake.nixosModules.cherrygrove = {lib, ...}: {
    # Avoid double-compressing memory.
    swapDevices = lib.mkForce [];
    zramSwap.enable = lib.mkForce false;
  };
}
