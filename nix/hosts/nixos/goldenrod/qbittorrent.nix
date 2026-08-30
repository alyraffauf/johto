_: {
  flake.nixosModules.goldenrod = {config, ...}: {
    networking.firewall = {
      allowedTCPPorts = [6881];
      allowedUDPPorts = [6881];
    };

    services.restic.backups.qbittorrent = {
      extraBackupArgs = [
        "--cleanup-cache"
        "--compression max"
        "--no-scan"
      ];
      paths = ["/mnt/Data/apps/qbittorrent"];
      repository = "rclone:b2:aly-backups/johto/${config.networking.hostName}/qbittorrent";
      initialize = true;
      inhibitsSleep = true;
      passwordFile = config.sops.secrets.restic-password.path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
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
