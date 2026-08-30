_: {
  flake.nixosModules.autoUpgrade = {config, ...}: {
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      dates = "02:00";
      fixedRandomDelay = true;
      flake = "github:alyraffauf/johto#${config.networking.hostName}";
      flags = ["--accept-flake-config"];
      operation = "switch";
      persistent = true;
      randomizedDelaySec = "45min";
      upgrade = false;
    };

    systemd.services.nixos-upgrade = {
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "15min";
      };

      unitConfig = {
        StartLimitBurst = 2;
        StartLimitIntervalSec = "1h";
      };
    };
  };
}
