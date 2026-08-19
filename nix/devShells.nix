_: {
  perSystem = {
    inputs',
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        inputs'.blzrd.packages.blzrd
        pkgs.git
        pkgs.fluxcd
        pkgs.bun
        pkgs.just
        pkgs.nh
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
