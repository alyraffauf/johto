_: {
  flake.nixosModules.cherrygrove = {lib, ...}: {
    # Cherrygrove receives these secrets from Goldenrod through the read-only share.
    sops.secrets.aly-password.neededForUsers = lib.mkForce false;
    system.activationScripts.setupSecrets = lib.mkForce "";
    users.users.aly.hashedPasswordFile = lib.mkForce "/run/host-secrets/aly-password";
  };
}
