# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Nix flake that declaratively configures macOS (nix-darwin) and Linux (NixOS) machines using Home Manager. The CLI tool `rig` (in `bin/rig`) is the primary interface for building and deploying configurations.

## Common commands

```sh
rig deploy              # Build and activate the current host (auto-detected)
rig deploy sigil        # Build and activate a specific host
rig deploy --update     # Update flake inputs, then build and activate
rig build               # Build without activating
rig check               # Run flake checks (evaluates all hosts)
rig fmt                 # Format all .nix files (nixfmt-rfc-style)
rig update              # Update flake inputs (nix flake update)
rig host                # Show the current host name
rig hosts               # List known hosts
rig context             # Show host config summary (profiles, apps, git state)
rig bootstrap           # First-time setup on a new machine
rig secrets scan        # Scan tracked files for plaintext secrets
sops secrets/secrets.yaml  # Edit encrypted secrets
```

The pre-commit hook runs `check-secrets --staged`. Install it with `rig install-hooks`.

## Architecture

### Host resolution

Hosts live under `hosts/darwin/<name>/` (or `hosts/nixos/<name>/`). Each host directory has a `default.nix` that exports `{ system, module }`. The `module` sets `platform.*` options and imports host-specific files. `lib/default.nix` auto-discovers hosts via `discoverHosts` and wires them into `darwinConfigurations`/`nixosConfigurations`.

Current darwin hosts: **atlas**, **hyperion**, **sigil**.

### The `platform` option namespace

All cross-cutting config lives under `platform.*` (defined in `modules/shared/core/options.nix`):

- `platform.user` — username, home, fullName, email
- `platform.host` — slug, title, platform, stateVersion, homeStateVersion
- `platform.apps` — shell (zsh/fish/nushell), editor (nvim/emacs/helix), enabledEditors, terminal, browser, notes, passwordManager
- `platform.profiles` — toggleable feature sets (base, desktop, development, media, personal, work)
- `platform.local` — repoRoot, gitInclude, sshConfig, zshLocal (paths for local overrides)
- `platform.packages.{home,system}` — merged package lists contributed by profiles
- `platform.secrets.stateDir` — runtime secrets directory populated by activation

### Profiles vs modules

**Profiles** (`profiles/`) are opt-in feature bundles toggled per-host via `platform.profiles.<name>.enable = true` in the host's `preferences.nix`. Each profile contributes packages and enables module behavior.

**Modules** (`modules/`) contain the implementation. They are structured by scope:
- `modules/shared/` — settings for all platforms (nixpkgs config, options)
- `modules/darwin/` — nix-darwin system config (activation, homebrew, macOS defaults, secrets)
- `modules/nixos/` — NixOS system config
- `modules/home/` — Home Manager config, organized by domain:
  - `core/` — git, ssh, env, ai (claude, lumen), worktrunk
  - `shell/` — zsh, fish, nushell, prompt (starship)
  - `editor/` — nvim (nixvim), emacs, helix
  - `desktop/` — ghostty, zellij, yazi, dock management
  - `media/` — music (beets, roon, openclaw)

### Module pattern for options

Feature submodules that expose host-level options (ai, dock, music) use a three-file pattern: `default.nix` (imports), `options.nix` (option declarations), `home.nix` (Home Manager implementation). Options declared in these `options.nix` files are imported at the system level in `modules/home/default.nix` so hosts can set them directly. Simpler modules are single `.nix` files (e.g., `core/git.nix`, `core/env.nix`).

### Local identity

`modules/local/identity.nix` is gitignored. It sets `platform.user.fullName` and `platform.user.email` for machines where these shouldn't be in the repo. See `identity.example.nix` for the template. The lib auto-includes it when the file exists.

### Secrets

Secrets are managed by **sops-nix** with age encryption. The age key lives at `~/.config/sops/age/keys.txt` (bootstrapped from `secrets/age-key.age` on first deploy). Encrypted secrets are in `secrets/secrets.yaml`. The `modules/darwin/core/secrets.nix` defines which secrets get decrypted and where.

### Overlays and packages

`overlays/default.nix` patches upstream packages (e.g., Emacs with macOS patches). `pkgs/default.nix` provides custom packages. Both are applied via the flake's `overlays.default` and `packages` outputs.

## Formatting

All Nix files use `nixfmt-rfc-style` (the flake's formatter). Run `rig fmt` before committing.

## Nix gotchas

- Always `git add` new files before building — Nix flakes ignore untracked files.
- Validate changes with `rig build` or `rig check` before committing.
- Tools may be available via the Nix store even if they're not on `$PATH` directly. Check `which`, `nix profile list`, or the flake's package set before concluding something isn't installed.

## Commit style

Commits use a `domain: lowercase description` format where the domain is the feature area being changed — not conventional-commits types. Examples from history:

```
gitignore: exclude worktree tracking directories
rig: add host context command and tooling hooks
python: wire up LSP, formatting, and dev tooling
terminal: add AI commit drafting, git workflow tools, and shell history
bootstrap: harden first-time deployment on new hosts
secrets: migrate secrets to sops-nix
editor: add emacs, helix, and modular nixvim configs
darwin: add hyperion and refine host defaults
```

Use an established domain from the repo history when one fits. Keep the description concise — one line, no bullet lists.

## Git workflow

- When rebasing or rewriting history, preserve original commit timestamps (`GIT_COMMITTER_DATE`) and SSH/GPG signatures.
- Sandbox restrictions can interfere with git signing, rebasing, and worktree operations. If a git operation fails with permission errors, retry with sandbox disabled.
- Before starting a history rewrite, check the current branch state and signing config to avoid mid-rebase failures.

## Branch targeting

Before making changes that span multiple files or repos, confirm the target branch and file locations. Misplacing work (wrong repo, wrong branch, wrong config file) is costly to revert.

## Adding a new host

1. Create `hosts/darwin/<name>/default.nix` with `{ system, module }` — set `platform.user` and `platform.host`
2. Create `hosts/darwin/<name>/preferences.nix` to enable profiles and set `platform.apps`
3. The host is auto-discovered by `lib/default.nix` — no flake.nix edits needed

## Local overrides (not in repo)

The system creates `~/.config/nix-darwin/README.md` listing local override paths:
- `~/.config/git/local.inc` — git config
- `~/.ssh/config.local*` — SSH config
- `~/.config/zsh/local.zsh` / `~/.config/nushell/local.nu` / `~/.config/fish/local.fish` — shell overrides
