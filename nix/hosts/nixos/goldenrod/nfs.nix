_: {
  flake.nixosModules.goldenrod = {
    networking.firewall.extraInputRules = ''
      -s 10.42.0.0/16 -p tcp --dport 2049 -j ACCEPT
      -s 10.42.0.0/16 -p udp --dport 2049 -j ACCEPT
    '';

    services.nfs.server = {
      enable = true;
      exports = ''
        /mnt/Data 100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash,fsid=0) 10.42.0.0/16(rw,sync,no_subtree_check,no_root_squash,fsid=0)
        /mnt/Media 100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash,fsid=1) 10.42.0.0/16(rw,sync,no_subtree_check,no_root_squash,fsid=1)
      '';
    };
  };
}
