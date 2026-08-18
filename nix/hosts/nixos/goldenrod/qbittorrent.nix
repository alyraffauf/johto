_: {
  flake.nixosModules.goldenrod = {
    config,
    pkgs,
    ...
  }: {
    services.qbittorrent = {
      enable = true;
      profileDir = "/var/lib/qbittorrent";
    };

    services.restic.backups.qbittorrent = let
      stop = service: "${pkgs.systemd}/bin/systemctl stop ${service}";
      start = service: "${pkgs.systemd}/bin/systemctl start ${service}";
    in {
      extraBackupArgs = [
        "--cleanup-cache"
        "--compression max"
        "--no-scan"
      ];
      backupCleanupCommand = start "qbittorrent";
      backupPrepareCommand = stop "qbittorrent";
      paths = [config.services.qbittorrent.profileDir];
      repository = "rclone:b2:aly-backups/johto/${config.networking.hostName}/qbittorrent";
      initialize = true;
      inhibitsSleep = true;
      passwordFile = config.sops.secrets.restic-password.path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
