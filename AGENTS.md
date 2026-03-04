# AGENTS.md

## Scope

These instructions apply to the entire repository.

## Repository purpose

This is a host-centric Nix dotfiles repo for macOS and Linux. Today it mainly
manages `nix-darwin` + Home Manager hosts on Apple Silicon Macs.

Primary entrypoints:

- `flake.nix`: flake inputs and outputs
- `bin/rig`: preferred wrapper for build, check, format, update, and secrets flows
- `hosts/`: per-machine definitions grouped by platform
- `profiles/`: reusable persona/capability bundles
- `modules/`: shared, platform, and Home Manager modules
- `config/`: checked-in app config mounted by Home Manager
- `secrets/`: encrypted secret material only

Current Darwin hosts:

- `atlas`
- `sigil`

## Working rules

- Prefer changing the narrowest layer that matches the task:
  - host-specific machine settings in `hosts/`
  - reusable feature toggles in `profiles/`
  - shared behavior in `modules/`
  - application config in `config/`
- Keep host definitions declarative. Follow the existing `dotfiles.*` option
  structure used in `hosts/darwin/*/default.nix`.
- Match the existing Nix style:
  - two-space indentation
  - trailing semicolons
  - small `let ... in` blocks when they improve readability
  - keep lists and attrsets formatted for `nixfmt-rfc-style`
- Shell scripts in `bin/` and `hooks/` should remain portable POSIX `sh` unless
  the file already requires something else.
- Reuse existing abstractions before adding new module options or profiles.

## Commands

Prefer the wrapper commands when they exist:

- format: `./bin/rig fmt`
- validation: `./bin/rig check`
- host build: `./bin/rig build`
- explicit host build: `./bin/rig build atlas` or `./bin/rig build sigil`
- list/detect hosts: `./bin/rig hosts`, `./bin/rig host`

Equivalent raw commands are acceptable when needed:

- `nix flake check`
- `nix build .#darwinConfigurations.atlas.system`
- `nix build .#darwinConfigurations.sigil.system`

Do not run activation commands such as `darwin-rebuild switch` or
`./bin/rig switch` unless the user explicitly asks for that. Builds and checks
are the safe default.

## Validation expectations

- Run `./bin/rig fmt` after editing Nix files or shell scripts.
- Run `./bin/rig check` for broad validation when changes can affect shared
  logic.
- If a change is host-specific, also build the affected host explicitly.
- If you touch secret-handling code or tracked files that may look sensitive,
  run `bin/check-secrets` or rely on the tracked pre-commit hook.

## Secrets and local state

- Never commit plaintext secrets.
- Never place secret values in `*.nix` files or tracked files under `config/`.
- Files under `secrets/` must stay encrypted as `*.age`.
- Use `./bin/rig secrets edit`, `./bin/rig secrets import`, and
  `./bin/rig secrets rekey` for secret changes instead of editing encrypted
  blobs by hand.
- Decrypted runtime secret material belongs under
  `$XDG_STATE_HOME/dotfiles/secrets` and must not be checked in.
- Machine-local identity belongs in the gitignored
  `modules/local/identity.nix`, based on `modules/local/identity.example.nix`.

## Change guidance

- Prefer repo-relative paths and existing helpers over ad hoc scripts.
- Avoid adding new dependencies or overlays unless the repo structure already
  points there as the right extension point.
- When changing Neovim, shell, or terminal config, check both the checked-in
  app config under `config/` and the corresponding Home Manager module under
  `modules/home/`.
- Keep documentation aligned with behavior when you add or rename commands,
  hosts, profiles, options, or secret workflows.
