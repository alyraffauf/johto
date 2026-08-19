_: {
  flake.nixosModules.goldenrod = {pkgs, ...}: let
    libvirtDefaultNetwork = "default";
  in {
    virtualisation.libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    systemd.services.libvirt-default-network = {
      description = "Start the libvirt default network";
      wantedBy = ["multi-user.target"];
      after = ["libvirtd.service"];
      requires = ["libvirtd.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        if ! ${pkgs.libvirt}/bin/virsh --connect qemu:///system net-list --name \
          | ${pkgs.gnugrep}/bin/grep --fixed-strings --line-regexp --quiet ${libvirtDefaultNetwork}; then
          ${pkgs.libvirt}/bin/virsh --connect qemu:///system net-start ${libvirtDefaultNetwork}
        fi
      '';
    };

    systemd.tmpfiles.rules = [
      "d /mnt/Data/vms 0750 root root - -"
      "d /var/lib/libvirt/boot 0755 root root - -"
    ];
  };
}
