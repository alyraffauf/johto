# Repository Guidelines

## Project Structure & Module Organization

`flake.nix` imports modules under `nix/`. Shared modules live in `nix/nixos/`; host state in `nix/hosts/nixos/<host>/`. VM assets live in `vms/hosts/<host>/`. `k8s/` contains workloads, charts, and Flux resources. OpenTofu is in `terraform/`, encrypted configuration in `secrets/`, public keys in `keys/`, and utilities in `scripts/`.

## Build, Test, and Development Commands

- `nix develop` enters the pinned shell with Bun, Just, OpenTofu, SOPS, and VM tooling. Direnv users can run `direnv allow`.
- `nix fmt` runs treefmt across Nix, YAML/JSON/Markdown, and shell files.
- `nix flake check` evaluates the complete flake and runs configured checks; this is the primary test command.
- `nix build .#nixosConfigurations.olivine.config.system.build.toplevel` builds one host without activating it. Replace `olivine` with `goldenrod` as needed.
- `bun run vms/create.ts <host> --check` validates a VM without provisioning it.
- `nix run .#vm-check -- <host>` and `nix run .#vm-provision -- <host>` run the reproducible VM workflow; the Just recipes are shortcuts.
- `just` lists maintenance recipes, including `just sops-edit tailscale.yaml` for encrypted secrets.

Run formatting and `nix flake check` before submitting changes. For host-specific work, also build the affected host output.

## Deployments

`nix/deployments.nix` registers `olivine` and `goldenrod` as nodes. After validation, run `blzrd switch olivine` or `blzrd switch goldenrod` to activate a host and set its boot default. Use `blzrd boot <host>` to stage without activation. Bare `blzrd switch` targets both nodes; use it deliberately.

## Coding Style & Naming Conventions

Let `nix fmt` define formatting through Alejandra, deadnix, statix, Prettier, shfmt, and ShellCheck. Use two-space indentation in Nix and YAML. Prefer composable modules and kebab-case filenames such as `prometheus-node.nix`. Keep Kubernetes resource names aligned with their workload and `kustomization.yaml` entries.

## Testing Guidelines

There is no separate unit-test framework or coverage threshold. Treat successful flake evaluation and affected-output builds as required validation. When editing Kubernetes manifests, verify that every added or renamed resource is referenced by the relevant kustomization and Flux definition.

## Commit & Pull Request Guidelines

History follows Conventional Commit-style subjects: `feat(scope): ...`, `fix(scope): ...`, `chore(scope): ...`, and `style(scope): ...`. Use an imperative, concise subject and a scope such as `storage`, `slingshot`, or `opentofu` when useful. Pull requests should explain the operational impact, identify affected hosts/services, link related issues when applicable, and list commands run. Call out migrations, restarts, or rollback concerns explicitly.

## Security & Configuration

Never commit decrypted secrets, private keys, OpenTofu state, or plans. Edit encrypted files through SOPS. After changing recipients in `keys/`, run `just sops-rekey` and review the encrypted diff before committing.
