_: {
  flake.nixosModules.canalave = {
    services.k3s = {
      role = "agent";
      serverAddr = "https://10.254.0.2:6443";

      extraFlags = [
        "--node-ip=10.254.0.3"
      ];
    };
  };
}
