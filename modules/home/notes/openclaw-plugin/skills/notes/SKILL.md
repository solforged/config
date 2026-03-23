---
name: notes
description: Capture conversations into a structured markdown notebook with enforced frontmatter, section ordering, and optional Taskwarrior sync.
---

# Notes

Use `notesctl` for conversation capture tasks on this host. Do not write markdown
files into the vault directly when the goal is a durable conversation note or a
task extraction flow.

## Use this when

- the user wants a conversation turned into a note in the vault
- the user wants follow-ups extracted into Taskwarrior
- the user wants a note that follows the repository-managed style guide
- the user wants a capture payload reviewed before it is written

## Commands

- `notesctl doctor`
- `notesctl render --input <payload.json>`
- `notesctl capture --input <payload.json>`
- `notesctl capture --input <payload.json> --dry-run`
- `notesctl capture --input <payload.json> --open`

## Payload rules

- pass structured JSON, not freeform markdown
- include `title` and `summary`
- prefer arrays for `people`, `tags`, `decisions`, `followups`, and `tasks`
- each task should at minimum include `description`
- preserve URLs or conversation identifiers in `source_url` or `conversation_id`

## Rules

- `notesctl` owns final markdown rendering and file writes
- do not bypass the style guide by writing custom headings manually
- when task sync is enabled, let `notesctl` assign or preserve task UUIDs
- use `--dry-run` when the user wants review before writing
