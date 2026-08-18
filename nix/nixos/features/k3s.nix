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
      extraFlags = ["--flannel-iface=johto"];
    };

    systemd.services.k3s = {
      after = ["wireguard-johto.service"];
      wants = ["wireguard-johto.service"];
    };
  };
}
