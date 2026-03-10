---
name: music
description: Use musicctl for read-only beets-backed music discovery, library inspection, and Roon bootstrap diagnostics on sigil.
---

# Music

Use `musicctl` for all music tasks on this host. Do not call `beet`, `roon-tui`,
Spotify tools, or Qobuz tools directly unless the user explicitly asks to debug
`musicctl` itself.

## Use this when

- the user wants to search or summarize the local music library
- the user wants recent additions, duplicate checks, or a closer look at an
  album or track
- the user wants to verify whether local Roon tooling is present

## Commands

- `musicctl doctor`
- `musicctl library stats`
- `musicctl library search <query>`
- `musicctl library recent`
- `musicctl library duplicates`
- `musicctl library inspect <album-or-track>`
- `musicctl roon doctor`

## Rules

- v1 is read-only, do not import, retag, move, delete, or rewrite files
- do not control playback
- do not try to drive `roon-tui` interactively
- if the user asks for a write operation, explain that the current music stack
  is inspection-only and offer a manual plan instead
