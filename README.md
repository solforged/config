# dotfiles

Host-centric Nix systems for macOS and Linux, currently centered on
`nix-darwin` + Home Manager for Apple silicon Macs.

This repo keeps machine definitions small, pushes reusable behavior into
profiles and modules, and uses `bin/rig` as the normal interface for builds,
checks, updates, and encrypted secrets workflows.

Current hosts:

- `atlas`: MacBook Pro, primary laptop
- `sigil`: Mac Studio, personal server

## Quick start

On an existing managed machine, start here:

```sh
./bin/rig hosts
./bin/rig host
./bin/rig check
./bin/rig build
```

If host auto-detection does not match the current machine, set it explicitly:

```sh
RIG_HOST=sigil ./bin/rig build
```

For a fresh macOS bootstrap:

1. Install Nix with the Determinate installer:

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
   ```

2. Do not run `sudo nix run ...` from this repo. Evaluating the flake as root
   can cause `HOME=/var/root` issues during the initial switch.

3. Use the wrapper for first-run bootstrap:

   ```sh
   ./bin/rig bootstrap sigil
   ```

`rig bootstrap` restores `~/.config/age/keys.txt` from Proton Pass when
needed, decrypts secrets for the target host, builds the system, and runs the
appropriate activation flow even before the machine is fully managed.

If you want the raw first-run commands instead of the wrapper:

```sh
nix build .#darwinConfigurations.sigil.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#sigil
```

Use `atlas` instead of `sigil` for the laptop bootstrap:

```sh
nix build .#darwinConfigurations.atlas.system
sudo ./result/sw/bin/darwin-rebuild switch --flake .#atlas
```

After the first activation, the normal workflow is:

```sh
./bin/rig switch
```

## Common workflows

### Validate changes

Use the wrapper by default:

```sh
./bin/rig fmt
./bin/rig check
```

Host-specific validation:

```sh
./bin/rig build atlas
./bin/rig build sigil
```

Equivalent raw commands:

```sh
nix flake check
nix build .#darwinConfigurations.atlas.system
nix build .#darwinConfigurations.sigil.system
```

### Apply configuration changes

Build without activating:

```sh
./bin/rig build
```

Switch the current machine:

```sh
./bin/rig switch
```

Switch an explicit host:

```sh
./bin/rig switch sigil
```

### Update flake inputs

```sh
./bin/rig update
./bin/rig build
```

Or update and apply in one step:

```sh
./bin/rig update-switch
```

### Work with secrets

Common secrets commands:

```sh
./bin/rig secrets decrypt
./bin/rig secrets edit shared/git/config.inc
./bin/rig secrets import ~/.ssh/sigil hosts/sigil/ssh/sigil
./bin/rig secrets init-host sigil
./bin/rig secrets recipient sigil
./bin/rig secrets rekey
./bin/rig secrets scan
./bin/rig install-hooks
```

The tracked pre-commit hook runs the same plaintext scan used by
`./bin/rig secrets scan`. Install it once per clone:

```sh
./bin/rig install-hooks
```

## Repository layout

- `flake.nix`: flake inputs and outputs
- `lib/`: thin host constructors for Darwin and future NixOS hosts
- `hosts/`: machine definitions grouped by platform
- `profiles/`: reusable persona and capability bundles
- `modules/`: shared, platform, and Home Manager modules
- `config/`: checked-in application config mounted by Home Manager
- `bin/rig`: wrapper for build, switch, check, format, update, and secrets flows
- `pkgs/`, `overlays/`: custom packages and overlays
- `secrets/`: encrypted files safe to commit

Choose the narrowest layer that matches the change:

- `hosts/` for machine-specific settings
- `profiles/` for reusable bundles such as `development`, `personal`, or `work`
- `modules/` for shared behavior and options
- `config/` for application config consumed by Home Manager

## Hosts and profiles

Hosts stay intentionally small. A host declares the machine identity, enabled
profiles, preferred apps, and a few feature toggles. For example:

- [hosts/darwin/atlas/default.nix](/Users/admin/.local/share/dotfiles/hosts/darwin/atlas/default.nix)
- [hosts/darwin/sigil/default.nix](/Users/admin/.local/share/dotfiles/hosts/darwin/sigil/default.nix)

Current profile usage:

- `atlas`: `base`, `desktop`, `development`, `work`
- `sigil`: `base`, `desktop`, `development`, `media`, `personal`

Profile files add reusable capability slices. A few examples:

- [profiles/base.nix](/Users/admin/.local/share/dotfiles/profiles/base.nix):
  common CLI packages
- [profiles/development.nix](/Users/admin/.local/share/dotfiles/profiles/development.nix):
  development-specific tooling and configuration
- [profiles/personal.nix](/Users/admin/.local/share/dotfiles/profiles/personal.nix):
  personal packages and GUI apps

When adding behavior that should apply to more than one host, prefer a profile
or a shared module before copying host-specific config.

## Secrets model

Plaintext secrets do not belong in `*.nix` files or tracked config under
`config/`.

Encrypted files live under `secrets/` and are safe to commit:

- `secrets/shared/`: decrypted on every host
- `secrets/work/`: decrypted only on hosts with the `work` profile
- `secrets/hosts/<host>/`: decrypted only on that host

Decrypted runtime material is written outside the repo:

```sh
$XDG_STATE_HOME/dotfiles/secrets
```

If `XDG_STATE_HOME` is unset, `rig` falls back to:

```sh
$HOME/.local/state/dotfiles/secrets
```

`rig switch` and `rig update-switch` automatically refresh decrypted secrets
before they build.

For recipients, import/edit flows, rekeying, and file layout details, see
[secrets/README.md](/Users/admin/.local/share/dotfiles/secrets/README.md).

## OpenClaw on sigil

`sigil` includes a host-specific OpenClaw setup managed through Home Manager
and `nix-openclaw`. The gateway stays bound to loopback and is published to the
tailnet through Tailscale `serve`, so it never has to listen on LAN or public
interfaces.

- Checked-in OpenClaw documents live in
  [config/openclaw/documents](/Users/admin/.local/share/dotfiles/config/openclaw/documents).
- Host-scoped OpenClaw secrets decrypt to
  `$XDG_STATE_HOME/dotfiles/secrets/openclaw` on `sigil`.
- The host module is
  [hosts/darwin/sigil/openclaw.nix](/Users/admin/.local/share/dotfiles/hosts/darwin/sigil/openclaw.nix).
- Keep identifying or environment-specific OpenClaw files local in the
  workspace instead of committing them. Typical local-only files are
  `USER.md`, research-profile notes, and detailed `TOOLS.md` content.

Create or refresh the encrypted secret files with:

```sh
./bin/rig secrets edit hosts/sigil/openclaw/brave-api-key
./bin/rig secrets edit hosts/sigil/openclaw/openai-api-key
./bin/rig secrets edit hosts/sigil/openclaw/telegram-bot-token
./bin/rig secrets edit hosts/sigil/openclaw/gateway-token
```

Tailscale on `sigil` is managed as a host-specific dependency:

- the macOS app is installed via Homebrew cask
- the `tailscale` CLI is installed in the system profile for OpenClaw and
  shell use
- OpenClaw keeps token auth enabled even on the tailnet

One-time bootstrap after `./bin/rig switch sigil`:

```sh
open -a Tailscale
tailscale status
```

Sign in through the Tailscale UI, approve the machine into the correct tailnet,
and leave MagicDNS enabled. After that, OpenClaw can publish privately through
`tailscale serve` without exposing the gateway beyond the tailnet.

Host-specific validation and rollout:

```sh
./bin/rig fmt
./bin/rig check
./bin/rig build sigil
```

Manual smoke test after `./bin/rig switch sigil`:

- confirm the launchd agent is loaded:
  `launchctl print gui/$UID/com.steipete.openclaw.gateway | grep state`
- confirm Tailscale is connected and serving the gateway privately:
  `tailscale status`
  `tailscale serve status`
- tail the gateway log:
  `tail -50 /tmp/openclaw/openclaw-gateway.log`
- verify the documents are symlinked under
  `$XDG_DATA_HOME/openclaw/workspace`
- send one Telegram message from an allowed account and confirm one OpenAI-backed
  response succeeds

## AI CLIs

The `development` profile now installs three local AI CLIs through Nix:

- `claude` via `pkgs.claude-code`
- `gemini` via `pkgs.gemini-cli`
- `codex` via `pkgs.codex`

Authentication is intended to stay interactive and account-backed rather than
committed as secrets:

- Claude Code stores its user config under `$XDG_DATA_HOME/claude` via
  `CLAUDE_CONFIG_DIR`, and Home Manager also links `~/.claude` there for
  compatibility. On first activation, if no user settings file exists, Home
  Manager initializes it with `forceLoginMethod = "claudeai"` so `claude`
  prefers the consumer Claude.ai login flow.
- Gemini CLI keeps its user settings in `~/.gemini/settings.json` upstream, so
  Home Manager links `~/.gemini` to `$XDG_DATA_HOME/gemini` to keep the writable
  state out of `$HOME`.
- Codex already uses `$CODEX_HOME`, which is set to `$XDG_DATA_HOME/codex` in
  the shared Home Manager base module.

After switching a host with the `development` profile, run each CLI once and
complete the browser login flow:

```sh
claude
gemini
codex
```

Use the consumer login options:

- `claude`: sign in with Claude.ai
- `gemini`: choose `Login with Google`
- `codex`: choose `Sign in with ChatGPT`

No encrypted secret files are required for those consumer flows. If you later
want API-key auth for any of them, keep the key in your normal local secret
overrides instead of committing it into the repo.

## Local-only overrides

Secrets and machine-local settings stay outside the flake and outside the Nix
store.

The initial config can reference these paths if you create them:

- `modules/local/identity.nix`
- `$XDG_STATE_HOME/dotfiles/secrets`
- `~/.config/git/local.inc`
- `~/.config/zsh/local.zsh`
- `~/.ssh/config.local`

To keep personal identity out of tracked host files, copy the example module:

```sh
cp modules/local/identity.example.nix modules/local/identity.nix
```

The local identity module is gitignored and can define:

```nix
{
  dotfiles.user = {
    fullName = "Your Name";
    email = "you@example.com";
  };
}
```

## Troubleshooting

Host detection fails:

```sh
./bin/rig hosts
RIG_HOST=atlas ./bin/rig build
```

Missing age identity during bootstrap:

- `rig bootstrap` creates `~/.config/age` automatically
- if `~/.config/age/keys.txt` is missing, it will prompt for Proton Pass login
- it then fetches `pass://Personal/age-identity/note`
- override that reference with `PROTON_PASS_AGE_IDENTITY_REF` if needed

Fresh-machine host naming on the laptop:

- use `atlas` explicitly on the first switch
- after activation renames the machine to `atlas`, normal host auto-detection
  works

Current upstream noise:

- Home Manager and nix-darwin may emit an `options.json` warning about
  `builtins.derivation` context; it does not currently block builds or switches
- Determinate-managed Nix settings on macOS are configured through the
  Determinate nix-darwin module rather than manual edits to
  `/etc/nix/nix.custom.conf`

## Reference commands

```sh
./bin/rig host
./bin/rig hosts
./bin/rig bootstrap sigil
./bin/rig build
./bin/rig build atlas
./bin/rig build sigil
./bin/rig switch
./bin/rig fmt
./bin/rig check
./bin/rig update
./bin/rig update-switch
./bin/rig secrets decrypt
./bin/rig secrets edit shared/git/config.inc
./bin/rig secrets import ~/.ssh/sigil hosts/sigil/ssh/sigil
./bin/rig secrets init-host sigil
./bin/rig secrets recipient sigil
./bin/rig secrets rekey
./bin/rig secrets scan
./bin/rig install-hooks
```
