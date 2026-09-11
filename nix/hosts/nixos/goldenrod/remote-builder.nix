_: {
  flake.nixosModules.goldenrod = {
    lib,
    pkgs,
    ...
  }: {
    users.groups.nix-remote-builder = {};

    users.users.nix-remote-builder = {
      isSystemUser = true;
      group = "nix-remote-builder";
      home = "/var/lib/nix-remote-builder";
      createHome = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        ''from="10.254.2.2",restrict,command="${pkgs.nix}/bin/nix-store --serve --write" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOCw7laVTIs9/VmQ6kWtxhlVyJ17oEpvo0WqxbZZiavo olivine-to-goldenrod-nix-builder''
      ];
    };

    nix.settings.trusted-users = lib.mkAfter ["nix-remote-builder"];
  };
}
