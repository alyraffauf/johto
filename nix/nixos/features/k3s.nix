_: {
  flake.nixosModules.k3s = {
    config,
    self,
    ...
  }: {
    sops.secrets.k3s-token = {
      sopsFile = self + "/secrets/k3s.yaml";
      key = "TOKEN";
      mode = "0400";
    };

    services.k3s = {
      enable = true;
      tokenFile = config.sops.secrets.k3s-token.path;
      extraFlags = ["--flannel-iface=sinnoh"];
    };

    systemd.services.k3s = {
      after = ["wireguard-sinnoh.service"];
      wants = ["wireguard-sinnoh.service"];
    };
  };
}
