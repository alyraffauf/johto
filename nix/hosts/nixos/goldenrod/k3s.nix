_: {
  flake.nixosModules.goldenrod = _: {
    services.k3s = {
      role = "agent";
      serverAddr = "https://10.254.2.2:6443";
      nodeLabel = ["johto.narwhal-snapper-ts.net/workload=media"];

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
  };
}
