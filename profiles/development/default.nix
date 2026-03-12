{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption;
  cfg = config.dotfiles;
  isDarwin = lib.hasSuffix "darwin" cfg.host.platform;
in
{
  options.dotfiles.profiles.development.enable = mkEnableOption "development tooling profile";

  config = lib.mkIf cfg.profiles.development.enable {
    dotfiles.ai.enable = true;

    dotfiles.ai.claude.settingsLocal = {
      permissions = {
        allow = [
          "Read"
          "Glob"
          "Grep"
          "LS"
          "Search"
          "Bash(find:*)"
          "Bash(cat:*)"
          "Bash(ls:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(rg:*)"
          "Bash(git:*)"
        ];
        deny = [
          "Read(.env*)"
          "Read(./secrets/**)"
        ];
      };
    };

    dotfiles.packages.home = with pkgs; [
      codex
      cargo
      clippy
      delve
      gemini-cli
      gh
      go
      gopls
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

    dotfiles.homebrew.casks = lib.optionals isDarwin [
      "codex-app"
    ];
  };
}
