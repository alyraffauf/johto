_: {
  flake.nixosModules.goldenrod = {config, ...}: {
    services.k3s = {
      role = "agent";
      serverAddr = "https://10.254.2.2:6443";
      nodeLabel = [
        "johto.narwhal-snapper-ts.net/workload=media"
        "johto.narwhal-snapper-ts.net/private-ingress=true"
      ];

      extraFlags = [
        "--data-dir=/var/lib/rancher/k3s-johto"
        "--node-ip=10.254.2.3"
        "--node-external-ip=136.55.177.16"
      ];
    };

    networking.firewall.allowedUDPPortRanges = [
      {
        from = 31667;
        to = 31680;
      }
    ];

    services.restic.backups.k3s-local-path = {
      paths = ["/var/lib/rancher/k3s/storage"];
      repository = "rclone:b2:aly-backups/johto/goldenrod/k3s-local-path";
      extraBackupArgs = [
        "--cleanup-cache"
        "--exclude=/var/lib/rancher/k3s/storage/*_cnpg-system_pg-shared-1/**"
      ];
      initialize = true;
      passwordFile = config.sops.secrets.restic-password.path;
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
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
