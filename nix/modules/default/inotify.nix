{lib, ...}: {
  flake.nixosModules.default = {
    boot.kernel.sysctl = {
      "fs.file-max" = lib.mkDefault 2097152;
      "fs.inotify.max_user_instances" = lib.mkOverride 100 8192;
      "fs.inotify.max_user_watches" = lib.mkOverride 100 524288;
    };
  };
}
