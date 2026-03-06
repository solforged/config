# Agenix

Recorded: March 9, 2026

## Current state

This repo already has a working `age`-based secrets workflow:

- encrypted files live under `secrets/`
- `bin/rig` handles decrypt, edit, import, rekey, and bootstrap flows
- consumers read runtime plaintext from `$XDG_STATE_HOME/dotfiles/secrets`

That model currently fits the repo shape: two Darwin hosts, a small secret
surface, and a clear separation between encrypted repo state and runtime
plaintext files.

## Decision

Do not add `agenix` yet.

The current `rig` + `age` workflow is good enough, and adopting `agenix` now
would mostly duplicate working custom machinery without enough payoff.

## Why not now

The current setup already covers the practical needs of this repo:

- encrypted secrets are safe to commit
- host-specific and shared secret scopes already exist
- bootstrap and day-to-day secret management already have one normal entrypoint
- Home Manager and host modules already consume runtime secret files directly

`agenix` would improve some aspects later, but those benefits are not strong
enough yet to justify migration cost and added Nix surface area.

## What `agenix` would improve later

If the repo grows, `agenix` would bring a few concrete advantages:

- declarative per-secret destination, owner, group, and mode
- tighter Nix integration for service secrets
- less custom shell logic if secret management keeps expanding
- secret declarations closer to the modules and services that consume them

## Revisit when

Revisit this decision if any of these become true:

- more hosts are added
- more services start consuming managed secrets
- secret ownership or mode management becomes painful
- secret declarations feel too far from the modules that consume them
- maintaining `rig secrets ...` starts taking noticeable time

## Migration shape if revisited

If `agenix` becomes worth it later, migrate incrementally:

- start with one host or one service class, not the whole tree at once
- keep the current age recipient model where practical
- avoid replacing the Proton Pass bootstrap flow unless that workflow is being
  intentionally redesigned

The goal of a future migration would be to reduce operational complexity, not
to replace working pieces for stylistic reasons.
