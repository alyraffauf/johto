_: {
  flake.nixosModules.wireguardJohto = {
    config,
    lib,
    pkgs,
    self,
    ...
  }: let
    nodes = {
      olivine = {
        address = "10.254.2.2";
        endpoint = "51.81.32.154:51820";
        publicKey = "v+Up5bpwOcV8Rg8r5oP5ru2gYezja4Db4+NHiiF+HUA=";
      };

      goldenrod = {
        address = "10.254.2.3";
        publicKey = "gzAi+LGwbC6VQXTKs/KCKp2Mu+JU6VQMb02z9rXfNDw=";
      };
    };

    hostName = config.networking.hostName;
    currentNode = nodes.${hostName};
    peerNodes = lib.filterAttrs (nodeName: _: nodeName != hostName) nodes;
    resolvectl = lib.getExe' pkgs.systemd "resolvectl";

    makePeer = _: node:
      {
        allowedIPs = ["${node.address}/32"];
        persistentKeepalive = 25;
        inherit (node) publicKey;
      }
      // lib.optionalAttrs (node ? endpoint) {inherit (node) endpoint;};
  in {
    sops.secrets.wireguard-johto-private = {
      sopsFile = self + "/secrets/wireguard-johto.yaml";
      key = hostName;
      mode = "0400";
    };

    networking = {
      firewall = {
        allowedUDPPorts = [51820];
        trustedInterfaces = lib.mkBefore ["johto"];
      };

      wireguard.interfaces.johto = {
        ips = ["${currentNode.address}/24"];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets.wireguard-johto-private.path;
        postSetup = ''
          ${resolvectl} dns johto 10.254.2.2
          ${resolvectl} domain johto ~johto
          ${resolvectl} default-route johto false
        '';
        peers = lib.mapAttrsToList makePeer peerNodes;
      };
    };

    services.resolved.enable = true;
    systemd.services.wireguard-johto.after = ["systemd-resolved.service"];
  };
}
