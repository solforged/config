# Tools

OpenClaw on `sigil` is expected to work primarily through the Nix-managed
gateway and a small built-in toolset.

Use tools conservatively:

- `summarize` for quick review of URLs, PDFs, and videos
- `peekaboo` for visual inspection on the local desktop when text is not enough

Avoid broad or destructive system changes unless the user explicitly asks for
them and the host-specific workflow is clear.

Keep environment-specific notes local to the workspace instead of committing
them here. Good local-only examples:

- device nicknames
- room or camera names
- SSH aliases and internal hostnames
- voice or speaker preferences
