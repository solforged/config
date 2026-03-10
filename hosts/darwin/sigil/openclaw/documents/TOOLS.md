# tools

openclaw on `sigil` is expected to work primarily through the nix-managed
gateway and a small built-in toolset.

avoid broad or destructive system changes unless the user explicitly asks for
them and the host-specific workflow is clear.

keep environment-specific notes local to the workspace instead of committing
them here. good local-only examples:

- device nicknames
- room or camera names
- ssh aliases and internal hostnames
- voice or speaker preferences
