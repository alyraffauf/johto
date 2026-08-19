_: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs'.blzrd.packages.blzrd
        pkgs.bun
        pkgs.cloud-utils
        pkgs.curl
        pkgs.fluxcd
        pkgs.git
        pkgs.just
        pkgs.libvirt
        pkgs.nh
        pkgs.opentofu
        pkgs.qemu-utils
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.virt-manager
      ];

      shellHook = ''
        export FLAKE="." NH_FLAKE="."
        echo "👋 Welcome to the johto devShell!"
      '';
    };
  };
}
