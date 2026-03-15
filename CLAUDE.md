# CLAUDE.md

## Critical rules

- Never run `darwin-rebuild switch` or `./bin/rig deploy` unless explicitly asked
- Never commit plaintext secrets. Secret values do not belong in `*.nix` files or tracked `config/` files
- This is a personal repo. Do not reference, name, or embed employer-specific information (team names, internal tools, internal URLs, corp hostnames) in any file. If editing from a work machine, stay aware of this boundary
- Always use `./bin/rig` commands over raw nix commands

## Context awareness

A startup hook (`.claude/scripts/context-check.sh`) runs on each prompt and reports
the current host context. Follow its guidance:
- **sigil** (personal): full repo scope
- **atlas** (work): do not embed employer-specific information in this repo.
  Suggest the work flake for work-only changes
- **unknown**: ask which context applies before making host-specific changes

## Repository map

Host-centric Nix dotfiles for macOS (nix-darwin + Home Manager).

- `flake.nix` — flake inputs and outputs
- `bin/rig` — preferred CLI for build, check, format, update, secrets
- `hosts/darwin/<hostname>/` — per-machine definitions; `preferences.nix` is the config entrypoint
- `profiles/` — reusable feature bundles (base, desktop, development, media, personal, work)
- `modules/` — shared, platform, and Home Manager modules
- `config/` — checked-in app config mounted by Home Manager
- `secrets/` — 1Password-backed manifest/docs for file and runtime secret flows

Darwin hosts: `atlas` (work), `sigil` (personal)

Option namespace: `platform.*` defined in `modules/shared/core/options.nix`. Key paths:
- `platform.user` — identity (name, email, home)
- `platform.host` — machine metadata
- `platform.apps` — shell, editor, terminal preferences
- `platform.profiles.*` — feature toggles
- `platform.features` — homebrew, dock, touchIdSudo, capsToCtrl

## Layering

Change the narrowest layer that fits:
1. Host-specific → `hosts/darwin/<hostname>/`
2. Reusable features → `profiles/`
3. Shared behavior → `modules/`
4. App config files → `config/`

Reuse existing abstractions before adding new module options or profiles.

## Style

- Two-space indent, trailing semicolons
- Small `let ... in` blocks for readability
- Format for `nixfmt-rfc-style`
- Shell scripts in `bin/` and `hooks/`: portable POSIX `sh` unless the file already requires otherwise

## Commands

Always use the wrapper:
- `./bin/rig fmt` — format nix and shell files
- `./bin/rig check` — run flake checks
- `./bin/rig build` — build current host
- `./bin/rig build <host>` — build a specific host
- `./bin/rig hosts` — list known hosts
- `./bin/rig secrets pull|scan` — manage 1Password-backed secret flows safely

Note: `rig fmt` and `rig check` may fail in sandboxed environments (e.g., work laptops with restricted nix daemon access). If they fail with sandbox or daemon errors, report the failure rather than retrying or working around it.

## Validation

- Run `./bin/rig fmt` after editing Nix or shell files
- Run `./bin/rig check` for changes to shared logic
- Build the affected host explicitly for host-specific changes
- For secret-related changes: `bin/check-secrets` or rely on the pre-commit hook

## Secrets

- Keep 1Password as the source of truth for secret values
- Use `./bin/rig secrets pull|scan` rather than ad hoc secret handling
- Decrypted runtime material: `$XDG_STATE_HOME/platform/secrets` (not tracked)
- Machine-local identity: gitignored `modules/local/identity.nix` (see `identity.example.nix`)

## Change guidance

- Prefer repo-relative paths and existing helpers
- Avoid new dependencies or overlays unless the repo structure already points there
- When changing editor, shell, or terminal config: check both `config/` and the corresponding `modules/home/` module
- Keep docs aligned with behavior when adding or renaming commands, hosts, profiles, or options
