# Work in Johto

Johto runs the home lab. `nix/hosts/nixos/` contains Olivine, Goldenrod, and Cherrygrove. `k8s/` contains Flux-managed workloads. `vms/` holds VM assets. `terraform/` manages Cloudflare DNS. Keep secrets in `secrets/` and public SOPS recipients in `keys/`.

## Check a change

Run `nix fmt` and `nix flake check` before you commit. Build the changed host.

```sh
nix build .#nixosConfigurations.olivine.config.system.build.toplevel
nix build .#nixosConfigurations.goldenrod.config.system.build.toplevel
nix build .#nixosConfigurations.cherrygrove.config.system.build.toplevel
```

If a NixOS host's `facter.json` changes, run `nix run github:alyraffauf/infra#generate-host-readmes`. Do not edit text between generated-section markers in a host README.

For VM work, run `nix run .#vm-check -- <host>`. Use `nix run .#vm-provision -- <host>` only when you intend to provision the VM.

When you change a Kubernetes resource, update its `kustomization.yaml` or Flux resource in the same change. For Terraform changes, run `tofu -chdir=terraform fmt -check` and `tofu -chdir=terraform plan` after direnv loads the credentials.

## Deploy deliberately

Flux deploys Kubernetes changes from `master`. Do not apply repository manifests with `kubectl` unless you are recovering the cluster. Use `blzrd switch olivine` or `blzrd switch goldenrod` only after validation. `blzrd boot <host>` changes the next boot without activating it. A bare `blzrd switch` targets both hosts.

The B2 state backend does not lock OpenTofu state. Review the plan before you apply, and never run concurrent applies.

## Keep secrets out of Git

Do not commit decrypted secrets, private keys, OpenTofu state, or saved plans. Edit secrets through SOPS. When `keys/` changes, run `just sops-rekey` and commit the updated `.sops.yaml` and encrypted files together.
