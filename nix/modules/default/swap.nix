_: {
  flake.nixosModules.default = {
    config,
    lib,
    ...
  }: let
    defaultSwapSizeMiB = 4096;
    kibibytesPerMebibyte = 1024;
    memoryDevices = config.hardware.facter.report.smbios.memory_device or [];
    installedMemoryKiB =
      lib.foldl' (
        total: device: total + (device.size or 0)
      )
      0
      memoryDevices;
    installedMemoryMiB = builtins.div installedMemoryKiB kibibytesPerMebibyte;
    swapSizeMiB =
      if installedMemoryMiB > 0
      then builtins.div installedMemoryMiB 2
      else defaultSwapSizeMiB;
  in {
    swapDevices = [
      {
        device = "/swapfile";
        size = swapSizeMiB;
        priority = 10;
        randomEncryption.enable = true;
      }
    ];
  };
}
