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
        pkgs.fluxcd
        pkgs.git
        pkgs.just
        pkgs.nh
        pkgs.nixd
        pkgs.opentofu
        pkgs.sops
        pkgs.ssh-to-age
      ];

      shellHook = ''
        export FLAKE="." NH_FLAKE="."
        echo "👋 Welcome to the johto devShell!"
      '';
    };
  };
}
