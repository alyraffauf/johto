_: {
  flake.nixosModules.goldenrod = {config, ...}: {
    services.prometheus = {
      enable = true;
      port = 3020;
      retentionTime = "30d";
      globalConfig = {
        scrape_interval = "30s";
        evaluation_interval = "30s";
      };
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            {
              targets = ["goldenrod.johto:3021"];
              labels.instance = "goldenrod";
            }
            {
              targets = ["olivine.johto:3021"];
              labels.instance = "olivine";
            }
          ];
        }
      ];
    };

    services.restic.backups.prometheus = {
      paths = ["/var/lib/prometheus2"];
      repository = "rclone:b2:aly-backups/johto/goldenrod/prometheus";
      extraBackupArgs = ["--cleanup-cache"];
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      pruneOpts = ["--keep-daily 7" "--keep-weekly 4" "--keep-monthly 12"];
      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
