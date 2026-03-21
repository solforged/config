# Nixvim Over LazyVim

This directory keeps Neovim Nix-first and capability-oriented.
We borrow useful ideas from LazyVim, but we do not embed its runtime or try to
mirror its file layout.

## Module map

- `core.nix`: editor defaults, theme, statusline, dashboard, shared UI
- `navigation.nix`: Telescope, Flash, which-key, searchable discovery
- `files-projects.nix`: file tree and project entry points
- `git-diagnostics.nix`: git UX, Trouble, TODO surfacing
- `lsp-formatting.nix`: LSP, completion, formatters
- `terminal-session.nix`: task runner, sessions, terminal glue, Zellij movement

## LazyVim intake map

| LazyVim area | Local equivalent | Status | Notes |
| --- | --- | --- | --- |
| Picker/search | Telescope + fzf-native | Adopted | Covers files, grep, buffers, commands, diagnostics, keymaps |
| Explorer/file ops | Neo-tree + Yazi | Adopted | Keep tree browsing in Neovim, heavier file work in Yazi |
| Discoverability | which-key + Telescope keymaps/help | Adopted | Prefer searchable help over memorizing plugin-specific conventions |
| Git UX | LazyGit + Gitsigns + Telescope git status | Adopted | Stronger terminal-native git flow than a full in-editor git UI |
| Diagnostics | Trouble + Telescope diagnostics | Adopted | Split between focused list and searchable picker |
| Sessions/dashboard | Custom sessions + dashboard-nvim | Adopted | Keep session logic local and declarative |
| Completion/LSP | `nvim-cmp` + built-in LSP + Conform | Adopted | Good enough today without chasing every upstream trend |
| Snacks picker/notifier | Current stack above | Deferred | Revisit if Telescope or UI ergonomics start feeling limiting |
| blink.cmp | `nvim-cmp` | Deferred | Worth watching, but not until Nixvim support clearly beats current stability |

## Review cadence

When a LazyVim feature looks compelling, translate it into one of the module
buckets above first. If it does not fit a bucket cleanly, it probably does not
belong in this config yet.
