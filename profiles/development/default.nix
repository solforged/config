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

    platform.ai.claude.settingsLocal = {
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

    platform.packages.home = with pkgs; [
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
