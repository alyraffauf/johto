_: {
  flake.nixosModules.goldenrod = {lib, ...}: {
    services.btrfs.autoScrub = {
      enable = true;
      fileSystems = lib.mkForce [
        "/"
        "/home"
        "/mnt/Data"
        "/mnt/Media"
      ];
      interval = "monthly";
    };
  };
}
