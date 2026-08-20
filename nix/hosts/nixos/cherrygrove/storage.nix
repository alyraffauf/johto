_: {
  flake.nixosModules.cherrygrove = {config, ...}: {
    microvm.volumes = [
      {
        image = "/mnt/Data/microvms/cherrygrove/nix-state.img";
        mountPoint = "/nix";
        size = 16384;
      }
      {
        image = "/mnt/Data/microvms/cherrygrove/nix-store-overlay.img";
        mountPoint = config.microvm.writableStoreOverlay;
        size = 122880;
      }
      {
        image = "/mnt/Data/microvms/cherrygrove/home.img";
        mountPoint = "/home";
        size = 122880;
      }
      {
        image = "/mnt/Data/microvms/cherrygrove/tailscale.img";
        mountPoint = "/var/lib/tailscale";
        size = 1024;
      }
      {
        image = "/mnt/Data/microvms/cherrygrove/ssh-host-keys.img";
        mountPoint = "/var/lib/ssh";
        size = 64;
      }
    ];

    # Persist /nix and /var/lib/ssh between boots.
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/var/lib/ssh".neededForBoot = true;

    services.openssh.hostKeys = [
      {
        bits = 4096;
        path = "/var/lib/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/var/lib/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    systemd.tmpfiles.rules = [
      "d /home/aly 0755 aly aly - -"
    ];
  };
}
