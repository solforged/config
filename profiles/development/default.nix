{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.platform;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.platform.profiles.development.enable = mkEnableOption "development tooling profile";

  config = lib.mkIf cfg.profiles.development.enable {
    platform.ai.enable = true;

    platform.ai.claude.settings = {
      extraKnownMarketplaces = {
        claude-plugins-official = {
          source = {
            source = "github";
            repo = "anthropics/claude-plugins-official";
          };
        };
      };
      permissions = {
        allow = [
          # Built-in read-only tools
          "Read"
          "Glob"
          "Grep"
          "WebFetch"
          "WebSearch"

          # Read-only Bash — file inspection
          "Bash(cat *)"
          "Bash(head *)"
          "Bash(tail *)"
          "Bash(less *)"
          "Bash(wc *)"
          "Bash(file *)"
          "Bash(stat *)"
          "Bash(ls *)"
          "Bash(tree *)"
          "Bash(find *)"
          "Bash(rg *)"
          "Bash(fd *)"
          "Bash(diff *)"
          "Bash(sort *)"
          "Bash(uniq *)"
          "Bash(jq *)"
          "Bash(du *)"
          "Bash(df *)"

          # Read-only Bash — system info
          "Bash(which *)"
          "Bash(echo *)"
          "Bash(pwd)"
          "Bash(env)"
          "Bash(printenv *)"
          "Bash(whoami)"
          "Bash(hostname)"
          "Bash(uname *)"
          "Bash(date *)"

          # Git — read-only operations
          "Bash(git status*)"
          "Bash(git log *)"
          "Bash(git log)"
          "Bash(git diff *)"
          "Bash(git diff)"
          "Bash(git show *)"
          "Bash(git show)"
          "Bash(git branch *)"
          "Bash(git branch)"
          "Bash(git remote *)"
          "Bash(git tag *)"
          "Bash(git tag)"
          "Bash(git rev-parse *)"
          "Bash(git ls-files *)"
          "Bash(git ls-files)"
          "Bash(git blame *)"
          "Bash(git stash list*)"

          # Nix — read-only
          "Bash(nix eval *)"
          "Bash(nix flake show *)"
          "Bash(nix flake metadata *)"

          # Read-only subagents
          "Agent(Explore)"
          "Agent(Plan)"
          "Agent(claude-code-guide)"
        ];
        deny = [
          "Read(.env*)"
          "Read(./secrets/**)"
        ];
      };
    };

    platform.packages.home = with pkgs; [
      inputs.claude-code-nix.packages.${cfg.host.platform}.claude-code-bun
      codex
      cargo
      clippy
      delve
      gemini-cli
      gh
      go
      gopls
      inputs.workmux.packages.${cfg.host.platform}.default
      memo
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.prettier
      pnpm
      pyright
      (lib.hiPrio python3)
      resvg
      ruff
      rust-analyzer
      rustc
      rustfmt
    ];

    platform.homebrew.casks = lib.optionals isDarwin [
      "codex"
      "codex-app"
      "claude"
    ];
  };
}
