_: {
  flake.nixosModules.goldenrod = {config, ...}: {
    services.restic.backups.immich = {
      extraBackupArgs = [
        "--cleanup-cache"
        "--compression max"
        "--no-scan"
      ];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/apps/immich"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/immich";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };

    services.restic.backups.nextcloud = {
      extraBackupArgs = ["--cleanup-cache" "--compression max" "--no-scan"];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/apps/nextcloud/html"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/nextcloud";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };

    services.restic.backups.paperless = {
      extraBackupArgs = ["--cleanup-cache" "--compression max" "--no-scan"];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/apps/paperless"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/paperless";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };

    services.restic.backups.uptime-kuma = {
      extraBackupArgs = ["--cleanup-cache" "--compression max" "--no-scan"];
      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["/mnt/Data/apps/uptime-kuma"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/uptime-kuma";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
