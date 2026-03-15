# 1Password-backed Secrets

Secrets do not live in this repo as encrypted blobs anymore. 1Password is the
source of truth, and the repo only keeps the wiring that tells `rig` or a
service where to fetch them from.

## File-backed secrets

`secrets/manifest` is for secrets that genuinely need to exist as files on
disk, such as Git includes and allowed-signers data.

`rig secrets pull` reads the manifest and writes those files to:

```sh
$XDG_STATE_HOME/platform/secrets
```

If `XDG_STATE_HOME` is unset, `rig` falls back to:

```sh
$HOME/.local/state/platform/secrets
```

The manifest format is:

```txt
<scope> <local-path> <op-uri>
```

Supported scopes:

- `shared`
- `work`
- `host:<name>`

Example:

```txt
shared git/config op://Private/git-config/notesPlain
host:sigil ssh/config op://Private/sigil-ssh-config/notesPlain
```

## Env-only secrets

Some consumers should not persist secrets to disk at all. Those integrations
should read directly from 1Password at runtime with `op read` and pass the
values through process-local environment variables.

`sigil`'s OpenClaw service follows that model for its gateway token, Telegram
bot token, and Brave API key.

## Commands

```sh
./bin/rig secrets pull
./bin/rig secrets pull sigil
./bin/rig secrets scan
./bin/rig install-hooks
```

Update secret values in 1Password directly. Change this repo only when the
local path, scope, or `op://` reference itself needs to move.
