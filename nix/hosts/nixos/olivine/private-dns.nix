{lib, ...}: {
  flake.nixosModules.olivine = {
    services.coredns = {
      enable = true;
      config = lib.concatStringsSep "\n" [
        "johto:53 {"
        "  bind 10.254.2.2"
        "  hosts {"
        "    10.254.2.2 olivine.johto"
        "    10.254.2.3 goldenrod.johto"
        "  }"
        "}"
      ];
    };

    systemd.services.coredns = {
      after = ["wireguard-johto.service"];
      requires = ["wireguard-johto.service"];
    };
  };
}
