_: {
  flake.nixosModules.cherrygrove = {
    systemd.network.networks."10-cherrygrove" = {
      matchConfig.MACAddress = "02:00:00:00:00:01";
      address = ["10.217.0.2/32"];

      routes = [
        {
          Destination = "10.217.0.1/32";
          GatewayOnLink = true;
        }
        {
          Destination = "0.0.0.0/0";
          Gateway = "10.217.0.1";
          GatewayOnLink = true;
        }
      ];

      networkConfig.DNS = ["1.1.1.1" "1.0.0.1"];
    };
  };
}
