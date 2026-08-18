_: {
  flake.nixosModules.default = {
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        "100.64.0.0/10"
        "10.254.0.0/24"
        "10.254.1.0/24"
      ];

      jails.sshd.settings = {
        enabled = true;
        bantime = "1h";
        findtime = "10m";
        maxretry = 5;
      };
    };
  };
}
