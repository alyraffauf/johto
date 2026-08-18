_: {
  flake.nixosModules.goldenrod = {
    services.k3s = {
      role = "agent";
      serverAddr = "https://10.254.2.2:6443";

      extraFlags = [
        "--node-ip=10.254.2.3"
      ];
    };
  };
}
