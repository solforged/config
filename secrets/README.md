# Encrypted Secrets

This tree stores encrypted files that are safe to commit. Plaintext secrets do
not belong in `*.nix` files or in tracked config under `config/`.

## Layout

- `shared/`: decrypted on every host
- `work/`: decrypted only on hosts whose profile includes `"work"`
- `hosts/<host>/`: decrypted only for that host

All decrypted outputs are written outside the repo to:

```sh
$XDG_STATE_HOME/dotfiles/secrets
```

If `XDG_STATE_HOME` is unset, `rig` falls back to:

```sh
$HOME/.local/state/dotfiles/secrets
```

The directory layout inside `secrets/` mirrors the runtime output path. For
example:

- `secrets/shared/git/config.inc.age` decrypts to `.../git/config.inc`
- `secrets/work/zsh/local.zsh.age` decrypts to `.../zsh/local.zsh`
- `secrets/hosts/atlas/ssh/config.age` decrypts to `.../ssh/config`

## Recipients

`rig secrets edit` and `rig secrets rekey` look for a `.age-recipients` file in
the target directory and then walk upward until `secrets/`.

Each `.age-recipients` file should contain one public recipient per line:

```txt
age1exampleexampleexampleexampleexampleexampleexampleexamplex
```

Copy the nearest `.age-recipients.example` file to `.age-recipients` before you
start creating encrypted files, or let `rig` initialize the host file from your
default age key:

```sh
./bin/rig secrets init-host sigil
```

By default `rig` decrypts with:

```sh
~/.config/age/keys.txt
```

Override that with `AGE_IDENTITIES_FILE` if needed.

## Commands

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

`rig deploy` and `rig deploy --update` automatically refresh decrypted secrets
before they build.
