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
          job_name = "bazarr";
          scrape_interval = "60s";
          scrape_timeout = "55s";
          static_configs = [{targets = ["bazarr.arr.svc.cluster.local:9708"];}];
        }
        {
          job_name = "lidarr";
          static_configs = [{targets = ["lidarr.arr.svc.cluster.local:9709"];}];
        }
        {
          job_name = "prowlarr";
          static_configs = [{targets = ["prowlarr.arr.svc.cluster.local:9710"];}];
        }
        {
          job_name = "radarr";
          static_configs = [{targets = ["radarr.arr.svc.cluster.local:9711"];}];
        }
        {
          job_name = "smartctl";
          static_configs = [
            {
              targets = ["127.0.0.1:9633"];
              labels.instance = "goldenrod";
            }
          ];
        }
        {
          job_name = "sonarr";
          static_configs = [{targets = ["sonarr.arr.svc.cluster.local:9712"];}];
        }
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

    services.resolved.settings.Resolve = {
      DNS = ["10.43.0.10"];
      Domains = ["~svc.cluster.local"];
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
