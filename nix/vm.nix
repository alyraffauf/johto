_: {
  perSystem = {
    system,
    pkgs,
    ...
  }:
    if system != "x86_64-linux"
    then {}
    else let
      repositorySource = ../.;
      vmRuntimeInputs = [
        pkgs.bun
        pkgs.curl
        pkgs.libvirt
        pkgs.qemu-utils
        pkgs.virt-manager
      ];
      vmCheck = pkgs.writeShellApplication {
        name = "vm-check";
        runtimeInputs = vmRuntimeInputs;
        text = ''
          exec ${pkgs.bun}/bin/bun run ${repositorySource}/vms/create.ts "$@" --check
        '';
      };
      vmProvision = pkgs.writeShellApplication {
        name = "vm-provision";
        runtimeInputs = vmRuntimeInputs;
        text = ''
          if [ "$EUID" -ne 0 ]; then
            exec ${pkgs.sudo}/bin/sudo "$0" "$@"
          fi

          exec ${pkgs.bun}/bin/bun run ${repositorySource}/vms/create.ts "$@"
        '';
      };
    in {
      packages = {
        vm-check = vmCheck;
        vm-provision = vmProvision;
      };
      apps = {
        vm-check = {
          type = "app";
          program = "${vmCheck}/bin/vm-check";
        };
        vm-provision = {
          type = "app";
          program = "${vmProvision}/bin/vm-provision";
        };
      };
    };
}
