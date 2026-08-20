_: {
  flake.nixosModules.cherrygrove = {
    microvm = {
      hypervisor = "cloud-hypervisor";
      mem = 10240;
      storeDiskType = "squashfs";
      vcpu = 4;
      vsock.cid = 3;
      writableStoreOverlay = "/nix/.rw-store";

      interfaces = [
        {
          id = "cherrygrove";
          mac = "02:00:00:00:00:01";
          type = "tap";
        }
      ];

      shares = [
        {
          mountPoint = "/run/host-secrets";
          proto = "virtiofs";
          readOnly = true;
          source = "/run/cherrygrove-secrets";
          tag = "host-secrets";
        }
      ];
    };
  };
}
