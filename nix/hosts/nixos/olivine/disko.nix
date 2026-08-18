_: {
  flake.nixosModules.olivine = {
    disko.devices = {
      disk.main = {
        device = "/dev/sda";
        type = "disk";

        content = {
          type = "gpt";

          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };

            root = {
              name = "root";
              size = "100%";

              content = {
                format = "ext4";
                mountOptions = ["defaults"];
                mountpoint = "/";
                type = "filesystem";
              };
            };
          };
        };
      };
    };
  };
}
