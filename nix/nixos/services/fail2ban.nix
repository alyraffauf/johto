_: {
  flake.nixosModules.default = {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        "100.64.0.0/10"
        "10.254.2.0/24"
      ];

      jails.sshd.settings = {
        enabled = true;
        bantime = "24h";
        findtime = "10m";
        maxretry = 5;
      };

      jails.recidive.settings = {
        backend = "systemd";
        bantime = "1w";
        enabled = true;
        findtime = "1d";
        maxretry = 5;
      };
    };
  };
}
