_: {
  flake.nixosModules.cherrygrove = {config, ...}: {
    networking.firewall = {
      allowedUDPPorts = [config.services.tailscale.port];
      trustedInterfaces = [config.services.tailscale.interfaceName];
    };

    services.tailscale = {
      enable = true;

      authKeyFile = "/run/host-secrets/tailscale-auth-key";
      extraUpFlags = ["--ssh" "--accept-routes"];
      openFirewall = true;
      useRoutingFeatures = "both";
    };
  };
}
