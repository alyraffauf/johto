_: {
  flake.nixosModules.goldenrod = {
    fileSystems = {
      "/mnt/Data" = {
        device = "/dev/disk/by-id/ata-CT4000BX500SSD1_2447E9959972";
        fsType = "btrfs";
        options = ["compress=zstd" "noatime" "nofail"];
      };

      "/mnt/Media" = {
        device = "/dev/disk/by-id/ata-ST14000NM001G-2KJ103_ZL201XNJ-part1";
        fsType = "btrfs";
        options = ["subvol=@media" "compress=zstd" "noatime" "nofail"];
      };
    };

    myNixOs.profile.b2media = {
      cacheDir = "/mnt/Data/.rclone-cache";
      audioCacheSize = "50G";
      audioReadAhead = "3G";
      videoCacheSize = "300G";
      videoReadAhead = "5G";
    };

    systemd.tmpfiles.rules = [
      "d /mnt/Data/apps 0755 root root - -"
      "d /mnt/Data/cache 0755 root root - -"
      "d /mnt/Data/user 0755 root root - -"
    ];
  };
}
