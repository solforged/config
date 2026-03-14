# Agenix

Recorded: March 9, 2026
Updated: March 14, 2026

## Current state

The age-based secrets layer was removed entirely in March 2026. Secrets now
live in 1Password and are pulled at runtime via `op` CLI. SSH private keys
are served by the 1Password SSH agent and never touch disk.

The `secrets/manifest` file maps scopes and local paths to `op://` URIs.
`rig secrets pull` reads the manifest and populates the runtime secrets
directory.

## Decision

Do not add `agenix`. There is no age encryption to manage declaratively.

The 1Password CLI approach removes encrypted files from the repo entirely,
which is a stronger security posture than age-encrypted files at rest.

## Previous context

Before this change, the repo used age-encrypted files in `secrets/` with
identity keys bootstrapped from Proton Pass via `pass-cli`. That layer was
removed because:

- The `secrets/` tree was empty (no `.age` files existed)
- 1Password provides both a CLI for secret retrieval and an SSH agent
- Eliminating encrypted files at rest simplifies the trust model
- A single `curl | sh` bootstrap flow becomes possible without age key management
