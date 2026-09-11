_: {
  flake.nixosModules.olivine = {
    config,
    self,
    ...
  }: {
    sops.secrets.nix-remote-builder-private = {
      sopsFile = self + "/secrets/nix-remote-builder.yaml";
      key = "private";
      mode = "0400";
    };

    nix = {
      buildMachines = [
        {
          hostName = "10.254.2.3";
          protocol = "ssh";
          sshUser = "nix-remote-builder";
          sshKey = config.sops.secrets.nix-remote-builder-private.path;
          system = "x86_64-linux";
          maxJobs = 1;
          speedFactor = 1;
          supportedFeatures = ["benchmark" "big-parallel" "kvm" "nixos-test"];
        }
      ];

      settings.builders-use-substitutes = true;
    };
  };
}
