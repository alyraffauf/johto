_: {
  flake.nixosModules.cherrygrove = {lib, ...}: {
    nix = {
      optimise.automatic = lib.mkForce false;
      settings.auto-optimise-store = false;
    };
  };
}
