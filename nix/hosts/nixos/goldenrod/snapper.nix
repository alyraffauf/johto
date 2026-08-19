_: {
  flake.nixosModules.goldenrod = {
    services.snapper = {
      configs = {
        home = {
          ALLOW_GROUPS = ["users"];
          FSTYPE = "btrfs";
          SUBVOLUME = "/home";
          TIMELINE_CLEANUP = true;
          TIMELINE_CREATE = true;
        };

        media = {
          ALLOW_GROUPS = ["users"];
          FSTYPE = "btrfs";
          SUBVOLUME = "/mnt/Media";
          TIMELINE_CLEANUP = true;
          TIMELINE_CREATE = true;
        };
      };

      filters = ''
        -.bash_profile
        -.bashrc
        -.cache
        -.config
        -.local
        -.nix-profile
        -.pki
        -.share
        -.snapshots
        -.zshrc
      '';

      persistentTimer = true;
    };
  };
}
