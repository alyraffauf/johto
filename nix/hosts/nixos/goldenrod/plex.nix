_: {
  flake.nixosModules.goldenrod = {config, ...}: {
    services.restic.backups.plex = {
      extraBackupArgs = [
        "--cleanup-cache"
        "--compression max"
        "--no-scan"
        "--exclude=/mnt/Data/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases"
      ];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/plex"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/plex";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
