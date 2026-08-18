_: {
  flake.nixosModules.goldenrod = {
    config,
    pkgs,
    self,
    ...
  }: let
    dataDirectory = "/mnt/Data";
  in {
    sops.secrets = {
      garage-nextcloud-access-key = {
        sopsFile = self + "/secrets/garage.yaml";
        key = "nextcloud_access_key";
        owner = "garage";
        group = "garage";
      };

      garage-nextcloud-secret-key = {
        sopsFile = self + "/secrets/garage.yaml";
        key = "nextcloud_secret_key";
        owner = "garage";
        group = "garage";
      };

      garage-rpc-secret = {
        sopsFile = self + "/secrets/garage.yaml";
        key = "rpc_secret";
        owner = "garage";
        group = "garage";
      };
    };

    sops.templates = {
      garage-config = {
        owner = "garage";
        group = "garage";
        mode = "0400";
        restartUnits = ["garage.service"];

        content = ''
          metadata_dir = "${dataDirectory}/garage/meta"
          data_dir = "${dataDirectory}/garage/data"
          db_engine = "sqlite"
          replication_factor = 1
          rpc_bind_addr = "[::]:3901"
          rpc_public_addr = "10.254.2.3:3901"
          rpc_secret = "${config.sops.placeholder.garage-rpc-secret}"

          [s3_api]
          api_bind_addr = "[::]:3900"
          s3_region = "garage"
        '';
      };

      garage-environment = {
        owner = "garage";
        group = "garage";
        mode = "0400";

        content = ''
          GARAGE_CONFIG_FILE=${config.sops.templates.garage-config.path}
          GARAGE_DEFAULT_ACCESS_KEY=${config.sops.placeholder.garage-nextcloud-access-key}
          GARAGE_DEFAULT_SECRET_KEY=${config.sops.placeholder.garage-nextcloud-secret-key}
          GARAGE_DEFAULT_BUCKET=aly-nextcloud
        '';
      };
    };

    users = {
      groups.garage = {};

      users.garage = {
        isSystemUser = true;
        group = "garage";
      };
    };

    systemd.tmpfiles.rules = [
      "d ${dataDirectory}/garage 0750 garage garage - -"
      "d ${dataDirectory}/garage/meta 0700 garage garage - -"
      "d ${dataDirectory}/garage/data 0700 garage garage - -"
    ];

    services.garage = {
      enable = true;
      package = pkgs.garage_2;
      environmentFile = config.sops.templates.garage-environment.path;

      settings = {
        metadata_dir = "${dataDirectory}/garage/meta";
        data_dir = "${dataDirectory}/garage/data";
      };
    };

    systemd.services.garage = {
      after = ["mnt-Data.mount"];
      requires = ["mnt-Data.mount"];
      serviceConfig = {
        DynamicUser = false;
        User = "garage";
        Group = "garage";
      };
    };

    services.restic.backups.garage = {
      backupCleanupCommand = "${pkgs.systemd}/bin/systemctl start garage";
      backupPrepareCommand = "${pkgs.systemd}/bin/systemctl stop garage";

      extraBackupArgs = [
        "--cleanup-cache"
        "--compression max"
        "--no-scan"
      ];

      inhibitsSleep = true;
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      paths = ["${dataDirectory}/garage"];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 3"
      ];

      rcloneConfigFile = config.sops.secrets.rclone-b2.path;
      repository = "rclone:b2:aly-backups/johto/goldenrod/garage";

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
