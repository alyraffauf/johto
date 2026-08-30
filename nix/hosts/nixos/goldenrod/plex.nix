_: {
  flake.nixosModules.goldenrod = {config, ...}: {
    networking.firewall = {
      allowedTCPPorts = [32400];
      allowedUDPPorts = [1900 32410 32412 32413 32414];
    };

    services.restic.backups.plex = {
      extraBackupArgs = [
        "--cleanup-cache"
        "--compression max"
        "--no-scan"
        "--exclude=/mnt/Data/apps/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
      ];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/apps/plex"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/plex";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };

    services.restic.backups.tautulli = {
      extraBackupArgs = ["--cleanup-cache" "--compression max" "--no-scan"];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/apps/tautulli"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/tautulli";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
